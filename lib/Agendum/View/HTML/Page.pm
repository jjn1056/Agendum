package Agendum::View::HTML::Page;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

sub title ($self) { die "title() must be implemented in a subclass" }

sub styles($self, $cb) {
  my $styles = $self->content('css') || return '';
  return $cb->($styles);
}

sub javascript($self, $cb) {
  my $styles = $self->content('js') || return '';
  return $cb->($styles);
}

__PACKAGE__->meta->make_immutable;
__DATA__
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= $self->title %></title>
    <link href="/static/global.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    %= $self->styles(sub($styles) {
      <style>
        %= $styles
      </style>
    % })
  </head>
  <body>
    <%= $content %>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
    %= $self->javascript(sub($js) {
      <style>
        %= $js
      </style>
    % })
  </body>
</html>