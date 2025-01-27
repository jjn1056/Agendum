package Agendum::Controller::Root;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

## ANY /...
sub root :At('/...') ($self, $c) { }

  ## ANY /@args
  sub not_found :At('/{*}') Via('root') ($self, $c, @args) {
    return $c->detach_error(404, +{error => "Requested URL not found."});
  }

  ## GET /static/@args
  sub static :Get('static/{*}') Via('root') ($self, $c, @args) {
    return $c->serve_file('static', @args) //
      $c->detach_error(404, +{error => "Requested URL not found."});
  }

  ## ANY /...
  sub public :At('/...') Via('root') ($self, $c) { }

  ## ANY /...
  sub private :At('/...') Via('root') ($self, $c) {
    return $c->redirect_to_action('/session/show') && $c->detach
      unless $c->user->authenticated;
  }

# The order of the Action Roles is important!!
sub end :Action Does('RenderErrors') Does('RenderView') { }

__PACKAGE__->config(namespace=>'');
__PACKAGE__->meta->make_immutable;
