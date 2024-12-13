package Agendum::Controller::Tasks::Task;

use CatalystX::Moose;
use Agendum::Syntax;
use Types::Standard qw(Int);

extends 'Agendum::Controller';

# ANY /tasks/...
sub root :At('/...') Via('../root') ($self, $c, $tasks) { $c->action->next($tasks) }

  # ANY /tasks/...
  sub build :At('/...') Via('root') ($self, $c, $tasks) {
    $self->view_for('create', task => my $new_task = $tasks->new_task);
    $c->action->next($new_task);
  }

    # GET /tasks/create
    sub show_create :Get('create') Via('build') ($self, $c, $new_task) { return }

    # POST /tasks/create
    sub create :Post('create') Via('build') BodyModel() QueryModel() ($self, $c, $new_task, $rm, $q) {
      return $self->process_request($new_task, $rm, $q);
    }

  # ANY /tasks/$id/...
  sub find :At('{:Int}/...') Via('root') ($self, $c, $tasks, $task_id) {
    my $task = $tasks->find_with_comments_labels($task_id) // return $c->detach_error(404);
    $self->view_for('update', task => $task);
    $c->action->next($task);
  }

    # GET /tasks/$id/update
    sub show_update :Get('update') Via('find') ($self, $c, $task) { return }

    # PATCH /tasks/$id/update
    sub update :Patch('update') Via('find') BodyModelFor('create') QueryModelFor('create') ($self, $c, $task, $rm, $q) {
      return $self->process_request($task, $rm, $q);
    }

sub process_request($self, $task, $rm, $q) {
  $task->set_columns_recursively($rm->nested_params);
  return $task->validate if $q->add_empty_comment;
  $task->insert_or_update;
  $self->view->saved(1) if $task->valid;
}

__PACKAGE__->meta->make_immutable;