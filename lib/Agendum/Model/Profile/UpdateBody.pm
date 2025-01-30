package Agendum::Model::Profile::UpdateBody;

use Moose;
use CatalystX::RequestModel;

extends 'Catalyst::Model';
namespace 'user_profile';
content_type 'application/x-www-form-urlencoded';

has email => (is=>'ro', property=>1);  
has first_name => (is=>'ro', property=>1);
has last_name => (is=>'ro', property=>1);
has profile => (is=>'ro', property=>+{model=>'::Profile' });

__PACKAGE__->meta->make_immutable();

package Agendum::Model::Profile::UpdateBody::Profile;

use Moose;
use CatalystX::RequestModel;

extends 'Catalyst::Model';

has address => (is=>'ro', property=>1);
has city => (is=>'ro', property=>1);
has state_id => (is=>'ro', property=>1);
has zip => (is=>'ro', property=>1);
has phone_number => (is=>'ro', property=>1);
has birthday => (is=>'ro', property=>1);
has employment_id => (is=>'ro', property=>1);

__PACKAGE__->meta->make_immutable();
