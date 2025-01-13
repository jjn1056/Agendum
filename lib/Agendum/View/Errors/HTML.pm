package Agendum::View::Errors::HTML;

use Moose;
use Agendum::Syntax;

extends 'Catalyst::View::Errors::HTML';

sub http_default($self, $c, $code, %args) {
   $c->view('HTML::Errors::Default', status_code=>$code, %args)->respond($code);
}

sub http_404($self, $c, %args) {
   $c->view('HTML::Errors::NotFound', %args)->respond(404);
}

sub http_403($self, $c, %args) {
   $c->view('HTML::Errors::Forbidden', %args)->respond(403);
}

sub http_400($self, $c, %args) {
   $c->view('HTML::Errors::BadRequest', %args)->respond(403);
}

__PACKAGE__->meta->make_immutable;
