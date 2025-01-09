package Agendum::Model::Tasks::ListQuery;

use Moose;
use CatalystX::QueryModel;
use Valiant::Validations;
use Agendum::Syntax;

extends 'Catalyst::Model';
namespace 'task';

has page => (is=>'ro', property=>1, default=>1);
has sort_column => (is=>'ro', property=>1, default=>'due_date');
has sort_direction => (is=>'ro', property=>1, default=>'asc'); 

validates page => (numericality=>'positive_integer', allow_blank=>1, strict=>1);
validates sort_column => (inclusion=>[qw/due_date priority status/], allow_blank=>1, strict=>1);
validates sort_direction => (inclusion=>[qw/asc desc/], allow_blank=>1, strict=>1);

sub BUILD($self, $args) { $self->validate }

__PACKAGE__->meta->make_immutable();
