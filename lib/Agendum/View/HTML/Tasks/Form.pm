package Agendum::View::HTML::Tasks::Form;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Fragment';

has task => ( is => 'ro', required => 1, export=>1 );
has saved => ( is => 'ro', required => 1 );

has action => (
  is => 'ro', 
  required => 1, 
  lazy => 1, 
  default => sub ($self) {
    return $self->task->in_storage
      ? $self->ctx->uri('update', [$self->task->task_id])
      : $self->ctx->uri('create');
  }
);

sub priority_options ($self) {
  return [
    ['1 - Low', 1],
    ['2 - Medium', 2],
    ['3 - High', 3],
    ['4 - Very High', 4],
    ['5 - Urgent', 5],
  ];
}

sub status_options ($self) {
  return [
    'pending',
    'in_progress',
    'on_hold',
    'blocked',
    'canceled',
    'completed',
  ];
}

sub labels ($self) {
  state $labels_rs = $self->ctx->model('Schema::Label')->search_rs;
  return ($labels_rs, id => 'name');
}

sub if_saved ($self, $cb) {
  ## only show if something was actually inserted or updated
  ## either in the parent or any child.
  if($self->saved) {
    return $cb->();
  } else {
    return '';
  }
}

sub task_form($self, $cb) {
  return $self->form_for('task', { action => $self->action }, $cb);
}

__PACKAGE__->meta->make_immutable;

__DATA__
#
# Style Content
#
% push_style(sub {
    /* Ensure the checkbox list wraps properly */
    .checkbox-list {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }
% })
#
# Main Content: Task Form
#
%= $self->task_form(sub($self, $fb, $task) {

   # Add a fieldset for task details
  <fieldset class="mb-4">
    %= $fb->legend({class=>"text-muted fs-5 mb-2 pb-1 border-bottom"})

    # Messages and global errors
    %= $fb->model_errors(+{class=>'alert alert-danger', role=>'alert', show_message_on_field_errors=>'Please fix validation errors'})
    %= $self->if_saved(sub {
      <div class="alert alert-success" role="alert">Successfully Updated</div>
    % })

    <div class="row g-3 px-2">

      # Add a title field
      <div class="col-12 mt-1">
        %= $fb->label('title', {class=>"form-label"})
        %= $fb->input('title', {class=>"form-control", errors_classes=>"is-invalid", placeholder=>"Enter task title here..."})
        %= $fb->errors_for('title', {show_empty=>1, class=>"invalid-feedback"})
      </div>

      # Add a description field
      <div class="col-12">
        %= $fb->label('description', {class=>"form-label"})
        %= $fb->text_area('description', {class=>"form-control", errors_classes=>"is-invalid", rows=>5, placeholder=>"Enter task description here..."})
        %= $fb->errors_for('description', {class=>"invalid-feedback"})
      </div>

      # Add a priority field
      <div class="col-md-4 col-sm-12">
        %= $fb->label('priority', {class=>"form-label"})
        %= $fb->select('priority', $self->priority_options, {class=>"form-control", errors_classes=>"is-invalid"})
        %= $fb->errors_for('priority', {class=>"invalid-feedback"})
      </div>

      # Add a due date field
      <div class="col-md-4 col-sm-12">
        %= $fb->label('due_date', {class=>"form-label"})
        %= $fb->date_field('due_date', {class=>"form-control", errors_classes=>"is-invalid"})
        %= $fb->errors_for('due_date', {class=>"invalid-feedback"})
      </div>

      # Add a status field
      <div class="col-md-4 col-sm-12">
        %= $fb->label('status', {class=>"form-label"})
        %= $fb->select('status', $self->status_options, {class=>"form-control", errors_classes=>"is-invalid"})
        %= $fb->errors_for('status', {class=>"invalid-feedback"})
        </select>
      </div>
    </div>
  </fieldset>

  # Add a fieldset for task labels
  <fieldset class="mb-4">
    %= $fb->legend_for('task_labels', +{class=>"text-muted fs-5 mb-2 pb-1 border-bottom"})
    %= $fb->collection_checkbox({task_labels => 'label_id'}, $self->labels, {class=>'checkbox-list px-2'}, sub($fb_labels) {
      <div class="form-check">
        %= $fb_labels->checkbox({class=>"form-check-input", errors_classes=>"is-invalid"})
        %= $fb_labels->label({class=>"form-check-label"})
      </div>
    % })
    %= $fb->errors_for('task_labels', {class=>"invalid-feedback"})
  </fieldset>

  # Comments
  <fieldset class="mb-4">
    %= $fb->legend_for('comments', {class=>"text-muted fs-5 mb-2 pb-1 border-bottom"})
      %= $fb->errors_for('comments', +{ class=>'alert alert-danger', role=>'alert' })
      <div class="col-12">
          %= $fb->fields_for('comments', sub($self, $fb_cc, $cc) {
            # If the comment is not in storage, show the text area, otherwise show the comment
            % if (!$cc->in_storage) {
              %= $fb_cc->text_area('content', {class=>"form-control", errors_classes=>"is-invalid", rows=>5, placeholder=>"Enter comment here..."})
              %= $fb_cc->errors_for('content', {class=>"invalid-feedback"})
            % } else {
              <div class="row">
                <div class="col-10">
                <small class="text-muted">$cc->created_at->strftime('%Y-%m-%d %H:%M %Z')</small>
                <p>$cc->content</p>
                </div>
                <div class="col-2">
                  %= $fb_cc->hidden('_delete') if $cc->is_marked_for_deletion
                  <%= $fb_cc->button(
                    '_delete',
                    {
                      class => "btn btn-danger w-100",
                      onclick => "return confirm('Are you sure you want to delete this comment?')", 
                      value => 1, 
                      disabled => $cc->is_marked_for_deletion,
                      type => "submit"
                    }, ($cc->is_marked_for_deletion ? 'Deleting':'Delete')) %>
                </div>
                %= $fb_cc->hidden('content')
              </div>
            % }
          % }, sub($self, $fb_final, $new_cc) {
            % if ($task->comments->count == 0) {
              <div class="alert alert-info" role="alert">No comments yet</div>
            % }
            % if( !$fb->errors_for('comments') && !$task->comments->final_comment_unstored ) {
              %= $fb_final->button( '_add', {class=>"btn btn-primary w-100", value=>1, type=>"submit"}, 'Add Comment') 
            % } 
          % }) 
      </div>
  </fieldset>

  # Show global errors and submit button
  <div>
    %= $fb->submit({class=>"btn mb-2 btn-primary w-100"})
    % if($task->in_storage) {
      <button 
        class="btn mb-2 btn-danger w-100"
        onclick="return confirm('Are you sure you want to delete this task?')"
        formaction="$self->ctx->uri('delete', [$task->task_id], {'x-tunneled-method'=>'delete'})">
          Delete $task->model_name->human
      </button>
    % }
    <a href="$self->ctx->uri('list')" class="btn btn-success w-100">Return to List</a>
  </div>
% })