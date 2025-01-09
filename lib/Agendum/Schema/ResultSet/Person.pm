package Agendum::Schema::ResultSet::Person;

use Agendum::Syntax;
use base 'Agendum::Schema::ResultSet';

sub unauthenticated_user($self, $args=+{}) {
  return $self->new_result($args);  
}

sub find_with_comments_labels ($self, $task_id) {
  return $self->with_comments_labels->find($task_id);
}

sub with_comments_labels ($self) {
  return $self->search({}, {
    prefetch=>[{'task_labels'=>'label'}, 'comments'],
    order_by=>{ -asc => [$self->me.'task_id', 'task_labels.label_id', 'comments.comment_id']},
  });
}

1;