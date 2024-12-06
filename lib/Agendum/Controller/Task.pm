package Agendum::Controller::Task;

use CatalystX::Moose;
use Agendum::Syntax;
use Types::Standard qw(Int);

extends 'Agendum::Controller';

has tasks => (
  is => 'rw',
  lazy => 1,
  default => sub { shift->ctx->model },
  handles => +{
    new_task => 'new_task',
    find_task => 'find_with_comments_labels',
    tasks_at_page => 'page',
  },
);

# ANY /task/...
sub root :At('/task/...') Via('../root') ($self, $c) { }

  # GET /task/list
  sub list :Get('list') Via('root') QueryModel() ($self, $c, $qm) {
    my $tasks = $self->tasks_at_page($qm->page);
    $self->tasks($tasks);
    return $self->view(tasks => $tasks);
  }

  # ANY /task/add/...
  sub prepare_add :At('add/...') Via('root') ($self, $c) {
    my $new_task = $self->new_task;
    $self->view_for('add', task => $new_task);
    $c->action->next($new_task);
  }

    # GET /task/add
    sub add :Get('') Via('prepare_add') ($self, $c, $new_task) { return }

    # POST /task/add
    sub create :Post('') Via('prepare_add') BodyModel() QueryModel() ($self, $c, $new_task, $rm, $q) {
      $new_task->set_columns_recursively($rm->nested_params);
      return $new_task->validate if $q->add_empty_comment;
      $new_task->insert;
      $self->view->saved(1) if $new_task->valid;
    }

  # ANY /task/update/...
  sub find :At('update/{:Int}/...') Via('root') ($self, $c, $task_id) {
    my $task = $self->find_task($task_id) // return $c->detach_error(404);
    $self->view_for('update', task => $task);
    $c->action->next($task);
  }

    # GET /task/update/$id
    sub update :Get('') Via('find') ($self, $c, $task) { return }

    # PATCH /task/update/$id
    sub save :Patch('') Via('find') BodyModelFor('create') QueryModelFor('create') ($self, $c, $task, $rm, $q) {
      $task->set_columns_recursively($rm->nested_params);
      return $task->validate if $q->add_empty_comment;
      $task->update;
      $self->view->saved(1) if $task->valid;
    }

__PACKAGE__->meta->make_immutable;