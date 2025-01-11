package Agendum::View::HTML::Session::Login;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';


sub title ($self) { return 'Login' }

has post_url => (is=>'ro', required=>1);


__PACKAGE__->meta->make_immutable;
__DATA__
#
# Custom Styles
#
% push_style(sub {
    .container {
      max-width: 800px;
    }
% })
#
# Main Content: Task List
#
%= view('HTML::Navbar', active_link=>'login')
<div class="container mt-5 mb-5">
  <h1>Login</h1>
  <p class="lead">Please login to continue.</p>
  <p>Access to this application is restricted to authorized users. </p>
  %= $self->form_with(+{action=>$self->post_url}, sub($self, $fb, $obj) {
    %= $fb->button('login', +{class=>'btn btn-primary w-30'}, 'Login via Catme.org')
  % })
</div>