package Agendum::Model::Session;

use Moose;
use Agendum::Syntax;

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


__PACKAGE__->meta->make_immutable;
