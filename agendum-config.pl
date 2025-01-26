return (
  disable_component_resolution_regex_fallback => 1,
  using_frontend_proxy => 1,
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
);