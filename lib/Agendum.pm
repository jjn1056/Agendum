package Agendum;

use URI;
use Moose;
use Catalyst;
use Valiant::I18N; # Needed to load $HOME/locale
use Agendum::Syntax;
use Agendum::Config;

# Needed to make sure logs are written to STDOUT and STDERR
# for docker container compatibility

use IO::Handle; STDERR->autoflush(1);

# Global plugins

__PACKAGE__->setup_plugins([qw/
  Session
  Session::State::Cookie
  Session::Store::Cookie
  RedirectTo
  URI
  Errors
  ServeFile
  CSRFToken
/]);

# Global configuration

__PACKAGE__->config(Agendum::Config->config());
__PACKAGE__->setup();

# Logged in user handling

has user => (
  is => 'rw',
  lazy => 1,
  required => 1,
  builder => '_get_user_from_session',
  clearer => 'clear_user',
);

sub _get_user_from_session($self) {
  return $self->model('Session')->has_user_id
    ? $self->model('Schema::Person')->find($self->model('Session')->user_id)
    : $self->model('Schema::Person')->unauthenticated_user;
}

sub login($self, $user, $email, $password) {
  return 0 unless $user->validate_credentials($email, $password)->valid;
  $self->set_user($user);
  return 1;
}

sub set_user($self, $user) {
  $self->user($user);
  $self->model('Session')->set_user($user);
}

sub logout($self) {
  $self->clear_user;
  $self->model('Session')->clear_user;
}

# Global helpers

sub is_development {
  return $ENV{AGENDUM_ENV} eq 'dev';
}

__PACKAGE__->meta->make_immutable();