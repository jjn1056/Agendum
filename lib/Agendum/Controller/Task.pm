package Agendum::Controller::Task;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

has tasks => (
  is => 'ro',
  lazy => 1,
  default => sub { shift->model('DBIC::Task') },
  shared => 1,
);

# ANY /task/...
sub root :At('/task/...') Via('../root') ($self, $c) { }

  # GET /task/list
  sub list :Get('list') Via('root') ($self, $c) { }

__PACKAGE__->meta->make_immutable;