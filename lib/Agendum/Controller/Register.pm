package Agendum::Controller::Register;

use CatalystX::Object;
use Agendum::Syntax;

extends 'Agendum::Controller';

has_shared user => (
  is => 'ro',
  lazy => 1,
  default => sub($self, $c) { $c->user },
);

sub root :At('register/...') Via('../public')  ($self, $c) {
  return $c->redirect_to_action('/home/user') && $c->detach
    if $self->user->registered;
}

  sub prepare_build :At('...') Via('root') ($self, $c) {
    return $self->view_for('build');
  }

    # GET /register/new
    sub build :Get('new') Via('prepare_build') ($self, $c) { return }

    # POST /register
    sub create :Post('') Via('prepare_build') BodyModel ($self, $c, $bm) {
      my $data = $bm->as_data([qw/
        email given_name family_name 
        password password_confirmation/]);
      return $c->redirect_to_action('/session/show')
        if $self->user->register($data)->valid;
    }

__PACKAGE__->meta->make_immutable; 
