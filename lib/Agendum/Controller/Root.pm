package Agendum::Controller::Root;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

## ANY /...
sub root :At('/...') ($self, $c) { }

  ## ANY /@args
  sub not_found :At('/{*}') Via('root') ($self, $c, @args) {
    return $c->detach_error(404, +{error => "Requested URL not found."});
  }

  ## GET /static/@args
  sub static :Get('static/{*}') Via('root') ($self, $c, @args) {
    return $c->serve_file('static', @args) //
      $c->detach_error(404, +{error => "Requested URL not found."});
  }

  ## GET /healthcheck
  sub healthcheck :Get('healthcheck') Via('root') ($self, $c) {
    return $c->res->body('OK');
  }

  ## GET /callback
  sub callback :Get('callback') Via('root') ($self, $c) {

    # Error if the state doesn't match
    $c->detach_error(400, +{error => "Invalid state."})
      unless $c->model('Session')->check_oauth2_state($c->req->param('state'));
    $c->model('Session')->clear_oauth2_state; # one time use

    my $code = $c->req->param('code');
    my $token = $c->model('Oauth2Client::Catme')->get_token($code, $c->uri_for('/callback'));
    $c->session->{access_token} = $token->{access_token};
    $c->session->{refresh_token} = $token->{refresh_token};
    my $id_token = $token->{id_token};

    my $id_info = $c->model('Oauth2Client::Catme')->decode_token($id_token);

    # sub => "catme:o9TLogCt1BFyjP", need to remove the catme: prefix
    my $public_id = $id_info->{sub}; $public_id =~ s/^catme://;

    my $person = $c->model('Schema::Person')->find_or_create({
      email => $id_info->{email},
      given_name => $id_info->{given_name},
      family_name => $id_info->{family_name},
      public_id => $public_id,
    }, {key=>'person_public_id'});

    $self->ctx->model('Session')->person_id($person->id);


    use Devel::Dwarn;
    Dwarn $id_info;
    Dwarn $token;

    $c->redirect_to_action('/home/user');

  }

  ## GET /logout
  sub logout :Get('logout') Via('root') ($self, $c) {
    $c->model('Session::User')->logout;
    return $c->redirect_to_action('/home/public');
  }

  ## GET /login
  sub login :Get('login') Via('root') ($self, $c) {
    my $state = $c->model('Session')->oauth2_state($c->generate_session_id);
    my $authorize_link = $c->model('Oauth2Client::Catme')
      ->authorize_link($c->uri('/callback'), $state);

    return $self->view(authorize_link=>$authorize_link);
  }

  ## ANY /...
  sub public :At('/...') Via('root') ($self, $c) { }

  ## ANY /...
  sub private :At('/...') Via('root') ($self, $c) {
    return $c->detach('/login') unless $c->model('Session::User')->authenticated;
  }

# The order of the Action Roles is important!!
sub end :Action Does('RenderErrors') Does('RenderView') { }

__PACKAGE__->config(namespace=>'');
__PACKAGE__->meta->make_immutable;
