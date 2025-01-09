package Agendum::Model::Oauth2Client::Catme;

use Moose;
use Agendum::Syntax;
use LWP::UserAgent;
use JSON::MaybeXS;
use URI;
use IO::Socket::SSL;
use Crypt::JWT 'decode_jwt';

extends 'Catalyst::Model';

my $ua = LWP::UserAgent->new;
# Disable SSL certificate verification for development
if(Agendum->is_development) {
    $ua->ssl_opts(
      SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE,
      verify_hostname => 0,
    );
}

has client_id => (is=>'ro', required=>1);
has client_secret => (is=>'ro', required=>1);
has open_id_conf_url => (is=>'ro', required=>1);
has jwks_uri => (is=>'ro', required=>1);

has open_id_configuration => (
  is => 'ro',
  lazy => 1,
  default => sub($self) {
    my $conf = $self->open_id_conf_url;
    my $res = $ua->get($conf);
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
    my $res = $ua->get($self->jwks_uri);
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

sub get_token($self, $code, $redirect_uri) {
  my $conf = $self->open_id_configuration;
  my $token_endpoint = URI->new($conf->{token_endpoint});
  my $res = $ua->post("$token_endpoint", [
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

sub decode_token($self, $token) {
  my $data = decode_jwt(token=>$token, kid_keys=>$self->jwks);
  return $data;
}






__PACKAGE__->meta->make_immutable;
