# use 'make dependencies' to manage this list.

requires 'Catalyst::Runtime', '5.90131';
requires 'CatalystX::RequestModel', '0.018';
requires 'Catalyst::ControllerPerContext', '0.008';
requires 'Catalyst::ControllerRole::At', '0.008';
requires 'Catalyst::Model::DBIC::Schema', '0.66';
requires 'Catalyst::View::EmbeddedPerl::PerRequest', '0.001006';
requires 'Catalyst::View::EmbeddedPerl::PerRequest::ValiantRole', '0.001004';
requires 'DBIx::Class', '0.082843';
requires 'DBIx::Class::BcryptColumn', '0.001003';
requires 'DBIx::Class::Helpers', '2.036000';
requires 'DBIx::Class::ResultClass::TrackColumns', '0.001002';
requires 'IO', '1.55';
requires 'Import::Into', '1.002005';
requires 'Moose', '2.2207';
requires 'Object::Tap', '1.000006';
requires 'Patterns::UndefObject', '0.004';
requires 'Plack', '1.0051';
requires 'base', '2.23';

# These are Catalyst Plugins that get loaded dynamically so are not
# detected by the scanner.  We need to add them manually and manage
# their versions manually. Also a few things used by the makefile
# like sqitch, etc.  (updated 12 Oct 2024)

requires 'Catalyst::Plugin::RedirectTo', '0.004';
requires 'Catalyst::Plugin::URI', '0.006';
requires 'Catalyst::Plugin::ServeFile', '0.004';
requires 'Catalyst::Plugin::CSRFToken', '0.007';
requires 'Catalyst::Plugin::Session', '.43';
requires 'Catalyst::Plugin::Session::Store::Cookie', '0.005';
requires 'Catalyst::Plugin::Session::State::Cookie', '0.18';
requires 'CatalystX::Errors', '0.001009';
requires 'Catalyst::ActionRole::RenderView', '0.002';
requires 'DBI', '1.645';
requires 'DBD::Pg', '3.18.0';
requires 'App::Sqitch', '1.4.1';
requires 'Server::Starter', '0.35';
requires 'Perl::PrereqScanner', '1.100';
requires 'Gazelle', '0.49';

# Test dependencies are currently manually managed. (updated 12 Oct 2024)

on test => sub {
  requires 'Test::Most' => '0.34';
  requires 'Test::Lib', '0.002';
  requires 'Test::DBIx::Class'=> '0.52';
};