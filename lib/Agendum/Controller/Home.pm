package Agendum::Controller::Home;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

## ANY /...
sub root :At('/...') Via('../public') ($self, $c) { }

  # If the user isn't authenticated, then they are public and
  # should see the public welcome page.  Otherwise the get the user
  # landing page

  # GET /
  sub public :Get('') Via('root') ($self, $c) {
    return $self->view();
  }

  # GET /  (but logged in)
  sub user :Get('') Via('root') Does(Authenticated) ($self, $c) {
    my ($userinfo, $err) = $c->model('WebService::Catme::API')->userinfo;  
    return $self->view(data=>$userinfo);
  }

__PACKAGE__->meta->make_immutable;