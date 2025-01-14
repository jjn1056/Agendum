package Agendum::Model::WebService::Catme::Auth;

use Moose;
use URI;
use Agendum::Syntax;
use LWP::UserAgent;
use JSON::MaybeXS;
use IO::Socket::SSL;
use Crypt::JWT 'decode_jwt';
use Data::Dumper;

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
    return $self->decode_json_defensive($res->decoded_content);
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
    return $self->decode_json_defensive($res->decoded_content);
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

# Given the authorization code, get the tokens.  Returns (tokens, error)
# where tokens is a hashref with the access_token, id_token, and refresh_token
# and error is a hashref with the error message.  If the error is undef, then
# the request was successful.  If the tokens are undef, then the request failed.

# If successful, then the tokens will be decoded and the decoded tokens will
# be added to the tokens hashref as 'decoded' keys.   Here's an example:

# {
#   access_token => '...',
#   id_token => '...',
#   refresh_token => '...',
#   decoded => {
#     access_token => {sub=>'...', exp=>...},
#     id_token => {sub=>'...', exp=>...},
#     refresh_token => {sub=>'...', exp=>...},
#   }
# }

sub _fetch_tokens($self, $params) {

  # Get the token endpoint from the OpenID configuration and then
  # post the request to that endpoint with the given parameters
  my $conf = $self->open_id_configuration;
  my $endpoint = URI->new($conf->{token_endpoint});
  my $res = $self->ua->post("$endpoint", [
    client_id     => $self->client_id,
    client_secret => $self->client_secret,
    %$params
  ]);

  # We expect JSON but decode defensively just in case
  my $response = $self->decode_json_defensive($res->decoded_content);

  # If the response is an error, then return the error message
  unless ($res->is_success) {
    my $error_data = Dumper($response);
    $self->_app->log->error("Failed to get tokens from $params->{grant_type}: $error_data");
    return (undef, $response->{detail});
  }

  # Otherwise decode the tokens and return them
  for my $key (qw(access_token id_token refresh_token)) {
    my ($decoded, $err) = $self->decode_catme_jwt($response->{$key});
    return (undef, $err) if $err;
    $response->{decoded}{$key} = $decoded;
  }
  return ($response, undef);
}

# Given an authorization code and a redirect_uri, get the tokens
sub get_tokens_from_code($self, $code, $redirect_uri) {
  return $self->_fetch_tokens({
    code         => $code,
    redirect_uri => $redirect_uri,
    grant_type   => 'authorization_code'
  });
}

# Given a refresh token, get the tokens
sub get_tokens_from_refresh($self, $refresh) {
  return $self->_fetch_tokens({
    refresh_token => $refresh,
    grant_type    => 'refresh_token'
  });
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

sub decode_json_defensive($self, $json) {
  my $data = eval { decode_json $json };
  return {detail=>$@, full=>$json} if $@;
  return $data;
}

__PACKAGE__->meta->make_immutable;
