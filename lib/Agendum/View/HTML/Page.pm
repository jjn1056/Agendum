package Agendum::View::HTML::Page;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

sub title ($self) { die "title() must be implemented in a subclass" }

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
      <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

    %= get_styles()
  </head>
  <body>
    # Main content section
    %= $content

    # Global footer section
    <footer class="bg-secondary text-light py-4">
      <div class="container">
        <div class="row">
          <!-- About Section -->
          <div class="col-md-4 mb-3">
            <h5>About</h5>
            <p class="small">
              Agendum helps you organize your tasks and stay productive. Join our community and simplify your workflow today.
            </p>
          </div>
          
          <!-- Navigation Links -->
          <div class="col-md-4 mb-3">
            <h5>Quick Links</h5>
            <ul class="list-unstyled">
              <li><a href="/" class="text-light text-decoration-none">Home</a></li>
              <li><a href="/task/list" class="text-light text-decoration-none">Tasks</a></li>
            </ul>
          </div>
          
          <!-- Social Media Section -->
          <div class="col-md-4">
            <h5>Follow Us</h5>
            <div class="d-flex">
              <a href="https://www.linkedin.com/in/jnapiorkowski/" class="text-light bi-linkedin text-decoration-none">&nbsp;john napiorkowski</a>
            </div>
          </div>
        </div>
        <div class="text-center mt-3">
          <p class="small mb-0">&copy; 2024 Agendum. All rights reserved.</p>
        </div>
      </div>
    </footer>

    # Scripts
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
    %= get_scripts()
  </body>
</html>