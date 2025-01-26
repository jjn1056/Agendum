package Agendum::Model::Register::CreateBody;

use Moose;
use CatalystX::RequestModel;
use Agendum::Syntax;

extends 'Catalyst::Model';

namespace 'user';
content_type 'application/x-www-form-urlencoded';

has email => (is=>'ro', property=>1);   
has given_name => (is=>'ro', property=>1);
has family_name => (is=>'ro', property=>1);
has password => (is=>'ro', property=>1);
has password_confirmation => (is=>'ro', property=>1);

__PACKAGE__->meta->make_immutable();