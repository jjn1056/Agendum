package Agendum::Model::Task::CreateQuery;

use Moose;
use CatalystX::QueryModel;
use Agendum::Syntax;

extends 'Catalyst::Model';

has add_empty_comment => (is=>'ro', property=>1, default=>0);   

__PACKAGE__->meta->make_immutable();

