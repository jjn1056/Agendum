package Agendum::Controller::Register;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

has user => (is=>'rw', default=>sub { shift->ctx->user });

sub root :At('register/...') Via('../public')  ($self, $c) {
  return $c->redirect_to_action('/home/user') && $c->detach
    if $self->user->registered;
}

  sub prepare_build :At('...') Via('root') ($self, $c) {
    return $self->view_for('build', user=>$self->user);
  }

    # GET /register/new
    sub build :Get('new') Via('prepare_build') ($self, $c) { return }

    # POST /register
    sub create :Post('') Via('prepare_build') BodyModel ($self, $c, $bm) {
      return $c->redirect_to_action('/session/show')
        if $self->user->register($bm)->valid;
    }

__PACKAGE__->meta->make_immutable; 
