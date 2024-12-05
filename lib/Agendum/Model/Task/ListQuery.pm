package Agendum::Model::Task::ListQuery;

use Moose;
use CatalystX::QueryModel;
use Valiant::Validations;
use Agendum::Syntax;

extends 'Catalyst::Model';
namespace 'task';

has page => (is=>'ro', property=>1, default=>1); 

validates page => (numericality=>'positive_integer', allow_blank=>1, strict=>1);

sub BUILD($self, $args) { $self->validate }

__PACKAGE__->meta->make_immutable();
