package Agendum::Model::Oauth2Client::Catme;

use Moose;
use URI;
use Agendum::Syntax;
use LWP::UserAgent;
use JSON::MaybeXS;
use IO::Socket::SSL;
use Crypt::JWT 'decode_jwt';

extends 'Catalyst::Model';
with 'Catalyst::Component::ApplicationAttribute';

has ua => (
  is=>'ro', 
  default=>sub($class) {
    my $ua = LWP::UserAgent->new;    
    if($class->_app->is_development) { # Disable SSL certificate verification for development
        $ua->ssl_opts(
          SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE,
          verify_hostname => 0,
        );
    }
    return $ua;
  }
);

has client_id => (is=>'ro', required=>1);
has client_secret => (is=>'ro', required=>1);
has open_id_conf_url => (is=>'ro', required=>1);
has jwks_uri => (is=>'ro', required=>1);

has open_id_configuration => (
  is => 'ro',
  lazy => 1,
  default => sub($self) {
    my $conf = $self->open_id_conf_url;
    my $res = $self->ua->get($conf);

    die "Failed to fetch OpenID configuration: ".$res->status_line
      unless $res->is_success;
    return decode_json($res->decoded_content);
  },
);

my @endpoints = qw(
  authorization_endpoint
  token_endpoint
  userinfo_endpoint
  jwks_uri
);

for my $attr (@endpoints) {
  has $attr => (
    is => 'ro',
    lazy => 1,
    required => 1,
    default => sub($self) { return $self->open_id_configuration->{$attr} },
  );
}

has jwks => (
  is => 'ro',
  lazy => 1,
  default => sub($self) {
    my $res = $self->ua->get($self->jwks_uri);
    die "Failed to fetch JWKS: ".$res->status_line
      unless $res->is_success;
    return decode_json($res->decoded_content);
  },
);

# Get the base URL from open_id_configuration and then build the full URL
# with all needed query parameters

sub authorize_link($self, $redirect_uri, $state) {
  my $conf = $self->open_id_configuration;
  my $authorize_endpoint = URI->new($conf->{authorization_endpoint});
  $authorize_endpoint->query_form(
    client_id => $self->client_id,
    state => $state,
    redirect_uri => $redirect_uri,
    response_type => 'code',
    scope => 'email openid profile admin_api_user_read admin_api_institutions_read admin_api_departments_read',
  );
  return $authorize_endpoint;
}

sub get_tokens($self, $code, $redirect_uri) {
  my $conf = $self->open_id_configuration;
  my $token_endpoint = URI->new($conf->{token_endpoint});
  my $res = $self->ua->post("$token_endpoint", [
    client_id => $self->client_id,
    client_secret => $self->client_secret,
    code => $code,
    redirect_uri => $redirect_uri,
    grant_type => 'authorization_code',
  ]);

  die "Failed to get token: ".$res->status_line
    unless $res->is_success;
  return decode_json($res->decoded_content);
}

# Verify the iss, aud, sub, and exp claims. algorithm???

sub decode_catme_jwt {
  my ($self, $token) = @_;
  my $err;
  my $jwt_info = eval {
    decode_jwt(
    token => $token,
    verify_exp => 1,
    kid_keys => $self->jwks);
  } || do {
    if($@ =~m/exp claim check failed/) {
      $err =  "Expired Token";
    } else {
      my ($safe_error) = ($@=~m/^(.+) at \//);
      $err = "Bad Token: $safe_error";
    }
  };
  return ($jwt_info, $err);
}

sub ACCEPT_CONTEXT($self, $c) {
  my $class = ref($self);
  my $per_context_self = $c->stash->{"__PerContext_${class}"} ||= do {
    my %args = (client_app=>$self, ctx=>$c);  
    Agendum::Model::Oauth2Client::Catme::PerContext->new(%args);
  };
  return $per_context_self;
}

Agendum::Model::Oauth2Client::Catme->meta->make_immutable;

package Agendum::Model::Oauth2Client::Catme::PerContext; 

use Moose;
#use Agendum::Syntax;

has ctx => (is=>'ro');
has id_info => (is=>'rw', predicate=>'has_id_info');

has client_app => (
  is=>'ro',
  required=>1, 
  handles=>[qw(authorize_link)],);

# If client is called with code and redirect_uri, then get the tokens
# and store them in the session.  Otherwise, look in the session for
# the tokens and return and build the client object with them.  Or die
# if they are not found.

sub client($self, @args) {
  if(@args) {
    my ($code, $redirect_uri) = @args;
    my $tokens = $self->client_app->get_tokens($code, $redirect_uri);

    # Validate each token we got from the server
    my %decoded;
    foreach my $type (qw/access_token refresh_token id_token/) {
      my ($decoded, $err) = $self->client_app->decode_catme_jwt($tokens->{$type});
      die "Bad Token: $err" if $err;
      $decoded{$type} = $decoded;
    }
    
    # Store the tokens in the session.  Store the unencoded access and refresh
    $self->ctx->session->{access_token} = $tokens->{access_token};
    $self->ctx->session->{refresh_token} = $tokens->{refresh_token};
    
    # Store the decoded id_token in id_info field, since we probably need it
    # to create or find the user, which is a typical step after getting the tokens
    # via the authorization code flow.
    $self->id_info($decoded{id_token});
  }

  return $self;
}

# build a $user_agent with the bearer access token, but first check that the
# access token won't expire in the next 5 minutes and if it will, then use the
# refresh token to get a new access token and refresh token.
#
# If the refresh fails then we need to signal the code we need to revalidate
# by logging into CATME

sub ua($self) {
  my $ua = LWP::UserAgent->new;
  if($self->has_access_token) {
    my $access_token = $self->ctx->session->{access_token};
    my ($decoded, $err) = $self->client_app->decode_jwt($access_token);
    die "Bad Token: $err" if $err;
    my $exp = $decoded->{exp};
    my $now = time;
    if($exp - $now < 60) {
      my $refresh_token = $self->refresh_token;
      my $tokens = $self->client_app->get_tokens($refresh_token);
      $self->ctx->session->{access_token} = $tokens->{access_token};
      $self->ctx->session->{refresh_token} = $tokens->{refresh_token};
    }
    $ua->default_header('Authorization' => "Bearer $access_token");
  }
  return $ua;
}

sub userinfo($self) {
  my $res = $self->ua->get($self->userinfo_endpoint);
  die "Failed to fetch userinfo: ".$res->status_line
    unless $res->is_success;
  return decode_json($res->decoded_content);
}


Agendum::Model::Oauth2Client::Catme::PerContext->meta->make_immutable;
