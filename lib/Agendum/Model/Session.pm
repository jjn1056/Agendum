package Agendum::Model::Session;

use Moose;
use Agendum::Syntax;
use Crypt::PRNG qw(random_bytes);
use MIME::Base64;


extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

has person_id => (is=>'rw', clearer=>'clear_person_id', predicate=>'has_person_id');
has oauth2_state => (is=>'rw', clearer=>'clear_oauth2_state', predicate=>'has_oauth2_state');
has access_token => (is=>'rw', clearer=>'clear_access_token', predicate=>'has_access_token');
has refresh_token => (is=>'rw', clearer=>'clear_refresh_token', predicate=>'has_refresh_token');

sub build_per_context_instance($self, $c) {
  return bless $c->session, ref($self);
}

# Set the access and refresh tokens in the session
sub set_oauth2_tokens($self, $access, $refresh) {
  $self->access_token($access);
  $self->refresh_token($refresh);
}

# Clear the person_id and the oauth2_state
sub logout($self) {
  $self->clear_person_id;
  $self->clear_oauth2_state;
  $self->clear_access_token;
  $self->clear_refresh_token;
}

sub check_oauth2_state($self, $state) {
  return $self->oauth2_state eq $state;
}

sub generate_oauth2_state($self) {
  my $length =  32; # Default length is 32 bytes
  my $random_bytes = random_bytes($length); # Generate cryptographically secure random bytes
  my $nonce = encode_base64($random_bytes, ''); # Encode to base64 (URL safe)
  $nonce =~ tr/+=\//-_/d; # Make it URL Query parameter safe

  $self->oauth2_state($nonce); # Save the nonce in the session
  return $nonce;
}

__PACKAGE__->meta->make_immutable;
