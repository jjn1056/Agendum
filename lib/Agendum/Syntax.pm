package Agendum::Syntax;

use strict;
use warnings;
use Import::Into;

# Used here for importing modules into the caller's namespace
use Patterns::UndefObject::maybe;
use Object::Tap;

sub importables {
  my ($class) = @_;
  return (
    # Perl 5.40 features: bitwise current_sub evalbytes fc isa
    #                     module_true postderef_qq say signatures
    #                     state try unicode_eval unicode_strings
    ['feature', ':5.40'],
    ['experimental', 'defer'],
    # Perl 5.40 builtins: true false weaken unweaken is_weak blessed refaddr 
    #                     reftype ceil floor is_tainted trim indexed
    ['builtin', 'load_module'],
    'utf8',
    'Patterns::UndefObject::maybe',
    'Object::Tap',
  );
}

sub import {
  my ($class, @args) = @_;
  my $caller = caller;
  foreach my $import_proto($class->importables) {
    my ($module, @args) = (ref($import_proto)||'') eq 'ARRAY' ? 
      @$import_proto : ($import_proto, ());
    $module->import::into($caller, @args)
  }
}

1;