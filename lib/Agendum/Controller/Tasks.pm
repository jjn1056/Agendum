package Agendum::Controller::Tasks;

use CatalystX::Object;
use Agendum::Syntax;

extends 'Agendum::Controller';

has_shared 'tasks', (
  default => sub ($self, $c) {
    return $c->user->search_related('tasks')->with_comments_labels;
  }
);

# ANY /tasks/...
sub root :At('/tasks/...') Via('../private') ($self, $c) { }

  # GET /tasks/list
  sub list :Get('list') Via('root') QueryModel() ($self, $c, $qm) {
    return $self->view(tasks => $self->tasks->page($qm->page));
  }

__PACKAGE__->meta->make_immutable;
