package Agendum::View::HTML::Home::Public;

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
  /* Custom Hero Styles */
  .hero {
    background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.7)), url('https://source.unsplash.com/1600x900/?nature') center/cover no-repeat;
    color: #fff;
    text-align: center;
    padding: 100px 0;
  }

  .hero h1 {
    font-size: 3rem;
    font-weight: bold;
    margin-bottom: 20px;
  }

  .hero p {
    font-size: 1.25rem;
    margin-bottom: 30px;
  }

  .hero .btn-primary {
    margin-right: 10px;
  }
%})
#
# Main Content
#
%= view('HTML::Navbar', active_link=>'home/public')
<!-- Hero Section -->
<header class="hero">
  <div class="container">
    <h1>Welcome to Agendum</h1>
    <p>Organize your tasks and boost your productivity with our powerful tools. Sign up today to simplify your workflow!</p>
  </div>
</header>

<!-- Supporting Content -->
<section class="py-5 bg-light">
  <div class="container text-center">
    <h2>Why Choose Agendum?</h2>
    <p class="lead mb-4">Discover features designed to make task management effortless and enjoyable.</p>
    <div class="row">
      <div class="col-md-4 mb-4">
        <i class="bi bi-check-circle-fill text-primary fs-1 mb-3"></i>
        <h5>Simple & Intuitive</h5>
        <p>Easily create, update, and manage your tasks with a clean and user-friendly interface.</p>
      </div>
      <div class="col-md-4 mb-4">
        <i class="bi bi-graph-up-arrow text-success fs-1 mb-3"></i>
        <h5>Boost Productivity</h5>
        <p>Track your progress and achieve your goals faster with built-in analytics.</p>
      </div>
      <div class="col-md-4 mb-4">
        <i class="bi bi-shield-lock-fill text-danger fs-1 mb-3"></i>
        <h5>Secure & Reliable</h5>
        <p>Your data is safe with us. We use state-of-the-art encryption to protect your information.</p>
      </div>
    </div>
  </div>
</section>
