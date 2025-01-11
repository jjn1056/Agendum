package Agendum::Model::WebService::Catme::API; 

use Moose;
use Agendum::Syntax;

with 'Catalyst::Component::InstancePerContext';

has ctx => (is=>'ro');
has auth => (is=>'ro', handles=>[qw(decode_json_defensive)]);

sub build_per_context_instance($self, $c) {
  my $class = ref($self) ? ref($self) : $self;
  return $class->new(
    ctx=>$c,
    auth=>$c->model('WebService::Catme::Auth')
  );
}

# Get the access token if we can.  return errors if we can't.
sub get_valid_access_token($self) {

  # Get the access token from the session, decode it.  If there is no error
  # and exp isnt' for another 60 seconds, then return the access token.

  my $access_token = $self->ctx->session->{access_token};
  my ($decoded, $decode_err) = $self->auth->decode_catme_jwt($access_token);
  return ($access_token, 0) unless $decode_err || $decoded->{exp} - time < 60;

  if($decode_err) {
    $self->ctx->log->info("Error decoding Access Token: $decode_err; refreshing");
  } else {
    $self->ctx->log->info("Access Token will expire in 60 seconds; refreshing");
  }

  my $refresh_token = $self->ctx->session->{refresh_token};
  my ($tokens, $err_get_tokens) = $self->auth->get_tokens_from_refresh($refresh_token);
  $self->ctx->log->error("Error getting tokens: $err_get_tokens") if $err_get_tokens;
  return (undef, $err_get_tokens) if $err_get_tokens;

  $self->ctx->session->{access_token} = $tokens->{access_token};
  $self->ctx->session->{refresh_token} = $tokens->{refresh_token};
  return ($tokens->{access_token}, 0);
}

# Get a user agent with the access token set.  Return errors if we can't.
# This is setup to create one user agent per request, so that we can avoid
# validating the access token over and over if you have multiple requests
# to the CATME API in a single location request.

sub ua($self) {
  return @{$self->ctx->stash->{'__catme_api_ua'}}
    if exists $self->ctx->stash->{'__catme_api_ua'};
  
  my ($ua, $err) = $self->_ua;
  return (undef, $err) if $err;

  $self->ctx->stash->{'__catme_api_ua'} = [$ua, $err];
  return ($ua, $err);
}

sub _ua($self) {
  my ($access_token, $err) = $self->get_valid_access_token;
  return (undef, $err) if $err;

  my $ua = $self->auth->ua->clone;
  $ua->default_header('Authorization' => "Bearer $access_token");

  return ($ua, 0);
}

## Below here are all the actual API calls

sub userinfo($self) {
  my ($ua, $err) = $self->ua;
  return (undef, $err) if $err;

  my $res = $ua->get($self->auth->userinfo_endpoint);
  my $data = $self->decode_json_defensive($res->decoded_content);

  return ($data, 0) if $res->is_success;
  $self->ctx->log->error("Failed to fetch userinfo: ".$res->status_line);
  return (undef, $data); # if not success, return the error
}

__PACKAGE__->meta->make_immutable;
