package Agendum::View::HTML::Register::Build;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has user => (is=>'ro', required=>1);

sub title ($self) { return 'Register' }

__PACKAGE__->meta->make_immutable;
__DATA__
#
# Custom Styles
#
% push_style(sub {

% })
#
# Main Content: Task List
#
%= view('HTML::Navbar', active_link=>'register')
<div class="container mt-5 mb-5 col-5 mx-auto">
  %= $self->form_for('user', {}, sub ($self, $fb, $user) {
    <fieldset class="mb-4">
      $fb->legend
      %= $fb->model_errors(+{class=>'alert alert-danger', role=>'alert', show_message_on_field_errors=>1})

      <div class="mb-3">
      $fb->label('given_name', {class=>"form-label"})
      $fb->input('given_name', {class=>"form-control", errors_classes=>"is-invalid"})
      $fb->errors_for('given_name', {show_empty=>1, class=>"invalid-feedback"})
      </div>

      <div class="mb-3">
      $fb->label('family_name', {class=>"form-label"})
      $fb->input('family_name', {class=>"form-control", errors_classes=>"is-invalid"})
      $fb->errors_for('family_name', {show_empty=>1, class=>"invalid-feedback"})
      </div>

      <div class="mb-3">
      $fb->label('email', {class=>"form-label"})
      $fb->input('email', {class=>"form-control", autocomplete=>"false", errors_classes=>"is-invalid"})
      $fb->errors_for('email', {show_empty=>1, class=>"invalid-feedback"})
      </div>

      <div class="mb-3">
      $fb->label('password', {class=>"form-label"})
      $fb->password('password', {class=>"form-control", autocomplete=>"new-password", errors_classes=>"is-invalid"})
      $fb->errors_for('password', {show_empty=>1, class=>"invalid-feedback"})
      </div>

      <div class="mb-3">
      $fb->label('password_confirmation', {class=>"form-label"})
      $fb->password('password_confirmation', {class=>"form-control", errors_classes=>"is-invalid"})
      $fb->errors_for('password_confirmation', {show_empty=>1, class=>"invalid-feedback"})
      </div>

    </fieldset>
    $fb->submit('Register',{class=>"btn btn-primary w-100 mb-2"})
    <div class='text-center'>
      $self->link_to($self->ctx->uri('/session/create'), {class=>"btn btn-primary w-100 mb-2"}, 'Login')
    </div>
  % })
</div>
