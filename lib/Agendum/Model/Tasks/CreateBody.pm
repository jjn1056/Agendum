package Agendum::Model::Tasks::CreateBody;

use Moose;
use CatalystX::RequestModel;
use Agendum::Syntax;

extends 'Catalyst::Model';

namespace 'task';
content_type 'application/x-www-form-urlencoded';

has title => (is=>'ro', property=>1);   
has description => (is=>'ro', property=>1);
has due_date => (is=>'ro', property=>1);
has priority => (is=>'ro', property=>1);
has status => (is=>'ro', property=>1);

has task_labels => (is=>'ro', property=>+{
  expand=>'JSON', 
  always_array=>1, 
  indexed=>1,
  model=>'::TaskLabel'
});

has comments => (is=>'ro', property=>+{ indexed=>1, model=>'::Comments' });

sub is_adding_comment ($self) {
  my $comments = $self->comments;
  return unless $comments;
  foreach my $comment (@$comments) {
    return 1 if $comment->_add;
  }
  return;
}

__PACKAGE__->meta->make_immutable();

package Agendum::Model::Tasks::CreateBody::TaskLabel;

use Moose;
use CatalystX::RequestModel;

extends 'Catalyst::Model';

has label_id => (is=>'ro', property=>1);

__PACKAGE__->meta->make_immutable();

package Agendum::Model::Tasks::CreateBody::Comments;

use Moose;
use CatalystX::RequestModel;

extends 'Catalyst::Model';

has comment_id => (is=>'ro', property=>1);
has content => (is=>'ro', property=>1);
has _add => (is=>'ro', property=>1);
has _delete => (is=>'ro', property=>1);

__PACKAGE__->meta->make_immutable();
