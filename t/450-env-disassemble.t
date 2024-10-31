#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;

use Allium::MOP;

use A::OP::Disassembler;
use A::MOP::Disassembler;

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

my $disassembler = A::MOP::Disassembler->new(
    op_disassembler => A::OP::Disassembler->new(
        instruction_set => A->new->instruction_set
    )
);

my $mop = Allium::MOP->new;

my $env = $disassembler->disassemble('Foo::');
isa_ok($env, 'Allium::Environment');

my ($BAZ, $bar, $foo) = sort { $a->symbol->name cmp $b->symbol->name } $env->bindings;

my $BAZ_sv = $mop->autovivify( $BAZ->symbol );
my $bar_cv = $mop->autovivify( $bar->symbol );
my $foo_cv = $mop->autovivify( $foo->symbol );

$mop->walk(sub ($glob, $depth) {
    say(('    ' x $depth),$glob);
    foreach my $g ($glob->stash->get_all_globs) {
        say(('    ' x $depth),'  > ',$g);
    }
});

#warn join ', ' => map $_->value, $bar, $BAZ, $foo;

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
