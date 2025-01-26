package Agendum::Model::Session;

use Moose;
use Agendum::Syntax;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

has user_id => (is=>'rw', clearer=>'clear_user_id', predicate=>'has_user_id');

sub build_per_context_instance($self, $c) {
  return bless $c->session, ref($self);
}

sub set_user($self, $user) {
  $self->user_id($user->id);
}

sub clear_user($self) {
  $self->clear_user_id;
}

__PACKAGE__->meta->make_immutable;
