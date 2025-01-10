package Agendum::View::HTML::Session::Logout;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';


sub title ($self) { return 'Logout' }


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
%= view('HTML::Navbar', active_link=>'')
<div class="container mt-5 mb-5">
  <h1>Logout</h1>
  <p class="lead">You have been logged out of the application</p>
  <p>You may wish to also log out of CATME</p>
 <a href="https://catme.org/login/logout" class="btn btn-primary w-30">Catme.org Logout</a>
</div>