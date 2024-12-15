package Agendum::Schema::ResultSet::Task;

use DateTime;
use Agendum::Syntax;
use base 'Agendum::Schema::ResultSet';

sub new_task ($self) {
  return $self->new_result({
    priority => 3,
    status => 'pending',
    due_date => DateTime->now->strftime('%Y-%m-%d'),
  });
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