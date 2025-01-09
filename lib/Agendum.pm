package Agendum;

use Catalyst;
use Valiant::I18N; # Needed to load $HOME/locale
use Moose;
use Agendum::Syntax;

# Needed to make sure logs are written to STDOUT and STDERR
# for docker container compatibility

use IO::Handle; STDERR->autoflush(1);

# Global plugins

__PACKAGE__->setup_plugins([qw/
  Session
  Session::State::Cookie
  Session::Store::Cookie
  RedirectTo
  URI
  Errors
  ServeFile
  CSRFToken
/]);

# Global configuration

__PACKAGE__->config(
  disable_component_resolution_regex_fallback => 1,
  using_frontend_proxy => 1,
  default_model => 'Schema::Task',
  'Plugin::Session' => { storage_secret_key => $ENV{SESSION_STORAGE_SECRET} },
  'Plugin::CSRFToken' => { auto_check =>1, default_secret => $ENV{CSRF_SECRET}, max_age=>36000 },
  'Model::Schema' => {
    traits => ['SchemaProxy'],
    schema_class => 'Agendum::Schema',
    connect_info => {
      dsn => "dbi:Pg:dbname=@{[ $ENV{POSTGRES_DB} ]};host=@{[ $ENV{DB_HOST} ]};port=@{[ $ENV{DB_PORT} ]}",
      user => $ENV{POSTGRES_USER},
      password => $ENV{POSTGRES_PASSWORD},
    },
  },
  'Model::Oauth2Client::Catme' => {
    client_id => $ENV{CATME_OAUTH2_CLIENT_ID},
    client_secret => $ENV{CATME_OAUTH2_CLIENT_SECRET},
    open_id_conf_url => $ENV{CATME_OAUTH2_OPENID_CONF},
    jwks_uri => $ENV{CATME_OAUTH2_JWKS_URI},
  },
);

sub is_development {
  return $ENV{AGENDUM_ENV} eq 'dev';
}

__PACKAGE__->setup();
__PACKAGE__->meta->make_immutable();