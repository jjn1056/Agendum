package Agendum::Model::Session::CallbackQuery;

use Moose;
use CatalystX::QueryModel;
use Agendum::Syntax;

extends 'Catalyst::Model';

has state => (is=>'ro', required=>0, property=>1);
has code => (is=>'ro', required=>0, property=>1);
has error => (is=>'ro', required=>0, predicate=>'has_error', property=>1);
has error_description => (is=>'ro', required=>0, property=>1);  

__PACKAGE__->meta->make_immutable();

