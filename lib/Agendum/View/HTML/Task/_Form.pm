package Agendum::View::HTML::Task::_Form;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

has task => ( is => 'ro', required => 1, export=>1 );

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
    ['Pending', 'pending'],
    ['In Progress', 'in_progress'],
    ['On Hold', 'on_hold'],
    ['Blocked', 'blocked'],
    ['Canceled', 'canceled'],
    ['Completed', 'completed'],
  ];
}

sub labels ($self) {
  return ($self->ctx->model('Schema::Label')->search_rs, id => 'name');
}

__PACKAGE__->meta->make_immutable;
__DATA__
# Style Content
#22
% content_append('css' => sub {
    /* Ensure the checkbox list wraps properly */
    .checkbox-list {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }
% })
# Main Content
# Main Content
# sdfsdfsdfsdf
  %= form_for('task', sub($self, $fb, $task) {
  <fieldset class="mb-4">
    %= $fb->legend({class=>"text-muted fs-5 mb-2 pb-1 border-bottom"})
    <div class="row g-3 px-2">
      <div class="col-12 mt-1">
        %= $fb->label('title', {class=>"form-label"})
        %= $fb->input('title', {class=>"form-control", errors_classes=>"is-invalid", placeholder=>"Enter task title here..."})
        %= $fb->errors_for('title', {show_empty=>1, class=>"invalid-feedback"})
      </div>
      <div class="col-12">
        %= $fb->label('description', {class=>"form-label"})
        %= $fb->text_area('description', {class=>"form-control", errors_classes=>"is-invalid", rows=>5, placeholder=>"Enter task description here..."})
        %= $fb->errors_for('description', {class=>"invalid-feedback"})
      </div>
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

      # sss
      <div class="col-md-4 col-sm-12">
        %= $fb->label('status', {class=>"form-label"})
        %= $fb->select('status', $self->status_options, {class=>"form-control", errors_classes=>"is-invalid"})
        %= $fb->errors_for('status', {class=>"invalid-feedback"})
        </select>
      </div>
    </div>
  </fieldset>
  <fieldset class="mb-4">
    %= $fb->legend_for('task_labels', +{class=>"text-muted fs-5 mb-2 pb-1 border-bottom"}),
    %= $fb->collection_checkbox({task_labels => 'label_id'}, $self->labels, {class=>'checkbox-list p-2'}, sub($fb_labels) {
      <div class="form-check">
        %= $fb_labels->checkbox({class=>"form-check-input", errors_classes=>"is-invalid"})
        %= $fb_labels->label({class=>"form-check-label"})
      </div>
    % })
    %= $fb->errors_for('task_labels', {class=>"invalid-feedback"})
  </fieldset>
  <div class="mt-3">
    %= $fb->model_errors(+{class=>'alert alert-danger', role=>'alert', show_message_on_field_errors=>'Please fix validation errors'})
    %= $fb->submit({class=>"btn btn-primary w-100"})
  </div>
% })
