package Agendum::Controller::Tasks;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

# ANY /tasks/...
sub root :At('/tasks/...') Via('../private') ($self, $c) {
  $c->action->next(my $tasks = $c->model->with_comments_labels);
}

  # GET /tasks/list
  sub list :Get('list') Via('root') QueryModel() ($self, $c, $tasks, $qm) {
    return $self->view(tasks => $tasks->page($qm->page));
  }

__PACKAGE__->meta->make_immutable;
