#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;

package Foo {
    our $BAZ;
    BEGIN { $BAZ = 'BAZ!!' }

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAZ;
    }
}

my $disassembler = A->new->mop_disassembler;
isa_ok($disassembler, 'A::MOP::Disassembler');

my $mop = $disassembler->disassemble('Foo::');
isa_ok($mop, 'Allium::MOP');

my $env = $mop->root_env;
isa_ok($env, 'Allium::Environment');

$mop->walk(sub ($glob, $depth) {
    say(('    ' x $depth),$glob);
    foreach my $g ($glob->stash->get_all_globs) {
        say(('    ' x $depth),'  > ',$g);
    }
});

my ($BAZ, $bar, $foo) = sort { $a->symbol->name cmp $b->symbol->name } $env->bindings;

isa_ok($BAZ, 'Allium::Environment::Binding');
isa_ok($BAZ->value, 'Allium::Environment::Value::Literal');
is($BAZ->value->literal, 'BAZ!!', '... got the expected literal value');

isa_ok($bar, 'Allium::Environment::Binding');
isa_ok($bar->value, 'Allium::Environment::Value::Optree');
isa_ok($bar->value->optree, 'Allium::Optree');

isa_ok($foo, 'Allium::Environment::Binding');
isa_ok($foo->value, 'Allium::Environment::Value::Optree');
isa_ok($foo->value->optree, 'Allium::Optree');

done_testing;
