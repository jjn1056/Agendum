package Agendum::Controller::Task;

use CatalystX::Moose;
use Agendum::Syntax;
use Types::Standard qw(Int);
use DateTime;

extends 'Agendum::Controller';

has tasks => (
  is => 'ro',
  lazy => 1,
  default => sub { shift->ctx->model },
);

has task => ( is => 'rw', predicate => 'has_task' );

sub prepare_new_task ($self) {
  $self->task($self->tasks->new_result({
    priority => 3,
    status => 'pending',
    due_date => DateTime->now->strftime('%Y-%m-%d'),
  }));
}

# ANY /task/...
sub root :At('/task/...') Via('../root') ($self, $c) { }

  # GET /task/list
  sub list :Get('list') Via('root') ($self, $c) {
    return $self->view(tasks => $self->tasks);
  }

  # ANY /task/add/...
  sub prepare_add :At('add/...') Via('root') ($self, $c) {
    $self->prepare_new_task;
    $self->view_for('add', task => $self->task);
  }

    # GET /task/add
    sub add :Get('') Via('prepare_add') ($self, $c) { return }

    # POST /task/add
    sub create :Post('') Via('prepare_add') BodyModel() ($self, $c, $task_request) {
      $self->task->set_from_request($task_request);
      return $c->redirect_to_action('list')
        if $self->task->valid;
    }

  # ANY /task/update/...
  sub find :At('update/{:Int}/...') Via('root') ($self, $c, $task_id) {
    $self->task($self->tasks->find($task_id));
    $self->view_for('update', task => $self->task);
  }

    # GET /task/update
    sub update :Get('') Via('find') ($self, $c) { return }

    # PATCH /task/update
    sub save :Patch('') Via('find') BodyModelFor('create') ($self, $c, $task_request) {
      $self->task->set_from_request($task_request);
      return $c->redirect_to_action('list')
        if $self->task->valid;
    }

__PACKAGE__->meta->make_immutable;