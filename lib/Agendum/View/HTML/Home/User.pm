package Agendum::View::HTML::Home::User;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

sub title ($self) { return 'Welcome to Agendum' }

__PACKAGE__->meta->make_immutable;
__DATA__
#
# Custom Styles
#
% push_style(sub {
%})
#
# Main Content
#
%= view('HTML::Navbar', active_link=>'home_user')
<div class="container mt-5 mb-5">
  <h1>Welcome</h1>
  <p class="lead">You have been logged into  the application</p>
  <p>If this was real life there'd be a list of things you could do here</p>
</div>
