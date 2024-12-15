package Agendum::View::HTML::Tasks::Task::Show;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has task => ( is => 'ro', required => 1, export => 1 );

sub title ($self) { return 'Task Details' }

sub priority_options ($self) {
  return [
    '1 - Low',
    '2 - Medium',
    '3 - High',
    '4 - Very High',
    '5 - Urgent',
  ];
}

__PACKAGE__->meta->make_immutable;
__DATA__
# Custom Styles
% push_style(sub {
    /* Add a maximum width to the form for desktop screens */
    .show-container {
      max-width: 800px;
    }
% })
# Main Content
%= view('HTML::Navbar', active_link=>'task_list')
<div class="container show-container mt-5 mb-5">
  <div class="card shadow-sm">
    <div class="card-header bg-primary text-white">
      <h5 class="mb-0">Task Details</h5>
    </div>
    <div class="card-body">
      <fieldset class="mb-4">
        <legend class="text-muted fs-5 mb-2 pb-1 border-bottom">$task->model_name->human Information</legend>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Title</label>
            <p class="form-control-plaintext">$task->title</p>
          </div>
          <div class="col-md-6">
            <label class="form-label">Priority</label>
            <p class="form-control-plaintext"><%= $self->priority_options->[$task->priority] %></p>
          </div>
          <div class="col-12">
            <label class="form-label">Description</label>
            <p class="form-control-plaintext">$task->description</p>
          </div>
          <div class="col-md-6">
            <label class="form-label">Due Date</label>
            <p class="form-control-plaintext">$task->due_date->strftime('%Y-%m-%d')</p>
          </div>
          <div class="col-md-6">
            <label class="form-label">Status</label>
            <p class="form-control-plaintext">$task->human_label_name($task->status)</p>
          </div>
        </div>
      </fieldset>

      <fieldset class="mb-4">
        <legend class="text-muted fs-5 mb-2 pb-1 border-bottom">$task->human_attribute_name('task_labels')</legend>
        <div class="row">
          <div class="col">
            <ul class="list-group">
              % if ($task->labels->count == 0) {
                <div class="alert alert-info mb-0" role="alert">No labels</div>
              % }
              % foreach my $label ($task->labels->all) {
                <li class="list-group-item">$task->human_label_name($label->name)</li>
              % }
            </ul>
          </div>
        </div>
      </fieldset>

      <fieldset class="mb-4">
        <legend class="text-muted fs-5 mb-2 pb-1 border-bottom">$task->human_attribute_name('comments')</legend>
        <ul class="list-group">
          % if ($task->comments->count == 0) {
            <div class="alert alert-info mb-0" role="alert">No comments</div>
          % }
          % for my $comment ($task->comments->all) {
            <li class="list-group-item">
              <small class="text-muted">$comment->created_at->strftime('%Y-%m-%d %H:%M %Z')</small>
              <p>$comment->content</p>
            </li>
          % }
        </ul>
      </fieldset>
    </div>
    <div class="card-footer">
      <div class="d-flex justify-content-between">
        <div class="d-flex gap-2">
          <a href="$self->ctx->uri('update',[$self->task->id])" class="btn btn-primary px-4">Edit</a>
          <form method="post" action="$self->ctx->uri('delete', [$self->task->id],{'x-tunneled-method'=>'delete'})">
            <button class="btn btn-danger px-4">Delete</button>
          </form>
        </div>
        <a href="$self->ctx->uri('../list')" class="btn btn-success px-4">Return to List</a>
      </div>
    </div>
  </div>
</div>
