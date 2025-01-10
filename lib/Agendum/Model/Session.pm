package Agendum::Model::Session;

use Moose;
use Agendum::Syntax;
use Crypt::PRNG qw(random_bytes);
use MIME::Base64;


extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

has person_id => (is=>'rw', clearer=>'clear_person_id', predicate=>'has_person_id');
has oauth2_state => (is=>'rw', clearer=>'clear_oauth2_state', predicate=>'has_oauth2_state');

sub build_per_context_instance($self, $c) {
  return bless $c->session, ref($self);
}

sub logout($self) {
  $self->clear_person_id;
}

sub check_oauth2_state($self, $state) {
  return $self->oauth2_state eq $state;
}

sub generate_oauth2_state($self) {
  my $length =  32; # Default length is 32 bytes
  my $random_bytes = random_bytes($length); # Generate cryptographically secure random bytes
  my $nonce = encode_base64($random_bytes, ''); # Encode to base64 (URL safe)
  $nonce =~ tr/+=\//-_/d; # Make it URL Query parameter safe
  $self->oauth2_state($nonce);
  return $nonce;
}

__PACKAGE__->meta->make_immutable;
