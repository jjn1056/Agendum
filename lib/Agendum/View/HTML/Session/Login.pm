package Agendum::View::HTML::Session::Login;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has user => (is=>'ro', required=>1);

sub title ($self) { return 'Login' }

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
%= view('HTML::Navbar', active_link=>'login')
<div class="container mt-5 mb-5 col-5 mx-auto">
  %= $self->form_for('user', +{}, sub($self, $fb, $obj) {

    # Fields
    <fieldset class="mb-4">
      <legend>Login</legend>
        <p class="lead">Please login to continue.</p>
        <p>Access to this application is restricted to authorized users. </p>
        %= $fb->model_errors(+{class=>'alert alert-danger', role=>'alert'})

      # Emails
      <div class="mb-3">
        %= $fb->label('email', {class=>"form-label"})
        %= $fb->input('email', {class=>"form-control", errors_classes=>"is-invalid"})
      </div>

      # Password
      <div class="mb-3">
        %= $fb->label('password', {class=>"form-label"})
        %= $fb->password('password', {class=>"form-control", errors_classes=>"is-invalid"})
      </div>
    </fieldset>

    # Buttons
    <div>
      %= $fb->submit('Sign In', {class=>"btn mb-2 btn-primary w-100"})
      <div class="text-center">
        $self->link_to($self->ctx->uri('/register/build'), {class=>"btn mb-2 btn-primary w-100"}, 'Register')
      </div>
    </div>
  % })
</div>
