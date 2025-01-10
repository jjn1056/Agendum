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
  $self->ctx->model('Session')->logout;
  $self->_user($self->ctx->model("Schema::Person")->unauthenticated_user);
}

# Given the decode id_token, find or create the Person object and set the session
# to that person.  Return the person object.

sub authenticate_user_from_id_token($self, %id_info) {
  my $person = $self->ctx->model("Schema::Person")->find_or_create({
    public_id => $id_info{sub},
    email => $id_info{email},
    given_name => $id_info{given_name},
    family_name => $id_info{family_name},
  }, {key=>'person_public_id'});

  $self->_user($person);
  $self->ctx->model('Session')->person_id($person->id);

  return $person;
}

sub AUTOLOAD($self, @args) {
    (my $method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method eq "DESTROY";

    return $self->_user->$method(@args);
}

__PACKAGE__->meta->make_immutable;