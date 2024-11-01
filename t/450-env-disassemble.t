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

#$mop->walk(sub ($glob, $depth) {
#    diag(('    ' x $depth),$glob);
#    foreach my $g ($glob->stash->get_all_globs) {
#        diag(('    ' x $depth),'  > ',$g);
#    }
#});

my ($BAZ, $bar, $foo) = sort { $a->symbol->name cmp $b->symbol->name } $env->bindings;

subtest '... check the BAZ binding' => sub {
    isa_ok($BAZ, 'Allium::Environment::Binding');
    isa_ok($BAZ->value, 'Allium::Environment::Value::Literal');
    is($BAZ->value->literal, 'BAZ!!', '... got the expected literal value');

    subtest '... check the BAZ SV in the MOP' => sub {
        my $BAZ_sv = $mop->lookup( $BAZ->symbol );
        isa_ok($BAZ_sv, 'Allium::MOP::ScalarValue');
        ok($BAZ_sv->has_binding, '... it has a binding');
        is(refaddr $BAZ_sv->get_binding, refaddr $BAZ, '... it is the same binding');
    };
};

subtest '... check the bar binding' => sub {
    isa_ok($bar, 'Allium::Environment::Binding');
    isa_ok($bar->value, 'Allium::Environment::Value::Optree');
    isa_ok($bar->value->optree, 'Allium::Optree');

    subtest '... check the bar CV in the MOP' => sub {
        my $bar_cv = $mop->lookup( $bar->symbol );
        isa_ok($bar_cv, 'Allium::MOP::CodeValue');
        ok($bar_cv->has_binding, '... it has a binding');
        is(refaddr $bar_cv->get_binding, refaddr $bar, '... it is the same binding');
    };
};

subtest '... check the foo binding' => sub {
    isa_ok($foo, 'Allium::Environment::Binding');
    isa_ok($foo->value, 'Allium::Environment::Value::Optree');
    isa_ok($foo->value->optree, 'Allium::Optree');

    subtest '... check the foo CV in the MOP' => sub {
        my $foo_cv = $mop->lookup( $foo->symbol );
        isa_ok($foo_cv, 'Allium::MOP::CodeValue');
        ok($foo_cv->has_binding, '... it has a binding');
        is(refaddr $foo_cv->get_binding, refaddr $foo, '... it is the same binding');
    };
};

done_testing;
