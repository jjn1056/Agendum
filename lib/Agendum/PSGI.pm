package Agendum::PSGI;

use Agendum;
use Agendum::Syntax;
use Plack::Runner;

sub to_app { Agendum->to_app }
sub run { Plack::Runner->run(@_, to_app()) }

sub call($command, @args) {
  return run(@args) if $command eq 'run';
  return to_app(@args) if $command eq 'to_app';
}

caller(1) ? 1 : call(@ARGV);