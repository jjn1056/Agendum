package Agendum::Controller::Home;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

## ANY /...
sub root :At('/...') Via('../public') ($self, $c) { }

  ## GET /
  sub index :At('/') Via('root') ($self, $c) {
    return $c->response
      ->$_tap(body=>'Welcome to Agendum')
      ->$_tap(content_type=>'text/html');
  }

__PACKAGE__->meta->make_immutable;