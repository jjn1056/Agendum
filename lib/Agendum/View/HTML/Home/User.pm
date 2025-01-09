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
You are logged in.
