package Agendum::Model::Session::User;

use Moose;
use Agendum::Syntax;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

has ctx => (is=>'ro');
has _user => (is=>'rw');

# If called with a person object, then set that to the user.  Otherwise
# if the session has a person_id then load that person object.  Otherwise
# set the user to the unauthenticated user.

# my $user = $c->model('Session::User'); # Returns or finds the current user
# $c->model('Session::User', $person); # Sets the user to $person

sub build_per_context_instance($self, $c) {
  my $user = $c->model('Session')->has_person_id 
    ? $c->model("Schema::Person")->find($c->model('Session')->person_id)
    : $c->model("Schema::Person")->unauthenticated_user;

  return ref($self)->new(ctx=>$c, _user=>$user);
}

sub logout($self) {
  my ($self) = @_;
  $self->ctx->model('Session')->logout;
  $self->_user($self->ctx->model("Schema::Person")->unauthenticated_user);
}

sub AUTOLOAD {
    my $self = shift;
    (my $method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method eq "DESTROY";

    return $self->_user->$method(@_);
}

__PACKAGE__->meta->make_immutable;