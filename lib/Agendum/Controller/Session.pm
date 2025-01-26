package Agendum::Controller::Session;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

has user => (is=>'ro', required=>1, default=>sub($self) {$self->ctx->user});

## ANY /...
sub root :At('/...') Via('../public') ($self, $c) { }

  ## ANY /login
  sub login :At('login/...') Via('root') ($self, $c) {
    $self->view_for('login', user => $self->user);
  }

    ## GET /login
    sub show :Get('') Via('login') ($self, $c) { } 

    ## POST /login
    sub create :Post('') Via('login') BodyModel ($self, $c, $bm) {
      return $c->redirect_to_action('/home/user')
        if $c->login($self->user, $bm->get(qw/email password/));
    }

  ## GET /logout
  sub logout :Get('logout') Via('root') ($self, $c) {
    $c->logout;
    return $self->view();
  }

__PACKAGE__->meta->make_immutable;
