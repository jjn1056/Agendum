package Agendum::Config;

use Agendum::Syntax;

sub db_schema($class) {
  return 'Agendum::Schema';
}

sub db_connect_info($class) {
  return {
    dsn => "dbi:Pg:dbname=@{[ $ENV{POSTGRES_DB} ]};host=@{[ $ENV{DB_HOST} ]};port=@{[ $ENV{DB_PORT} ]}",
    user => $ENV{POSTGRES_USER},
    password => $ENV{POSTGRES_PASSWORD},
  };
}

sub catalyst($class) {
  return (
    disable_component_resolution_regex_fallback => 1,
    using_frontend_proxy => 1,
    'Plugin::Session' => { storage_secret_key => $ENV{SESSION_STORAGE_SECRET} },
    'Plugin::CSRFToken' => { auto_check =>1, default_secret => $ENV{CSRF_SECRET}, max_age=>36000 },
    'Model::Schema' => {
      traits => ['SchemaProxy'],
      schema_class => $class->db_schema(),
      connect_info => $class->db_connect_info(),
    },
  );  
}

caller(1) ? 1 : __PACKAGE__->config();