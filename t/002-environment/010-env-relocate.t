#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;

use Allium::Environment;

package Foo {
    our $BAR = 'huh?';
    BEGIN { $BAR = 'BAR!!' }

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAR;
    }
}

my $A = A->new;

my $foo = $A->op_disassembler->disassemble(\&Foo::foo);
isa_ok($foo, 'Allium::Optree');

my $bar = $A->op_disassembler->disassemble(\&Foo::bar);
isa_ok($bar, 'Allium::Optree');

my $env = Allium::Environment->new;
isa_ok($env, 'Allium::Environment');
$env->bind( $env->parse_symbol('$Foo::BAR'), $env->wrap_literal('BAR!!') );
$env->bind( $env->parse_symbol('&Foo::foo'), $env->wrap_optree($foo) );
$env->bind( $env->parse_symbol('&Foo::bar'), $env->wrap_optree($bar) );

my $new_env = $env->relocate([ 'Bar::' ]);

my @binds = $new_env->bindings;
isa_ok($_, 'Allium::Environment::Binding') foreach @binds;

my @symbols = map $_->symbol, $env->bindings;
my @values  = ('BAR!!', $foo, $bar);

foreach my ($i, $b) (indexed $new_env->bindings) {
    isa_ok($b, 'Allium::Environment::Binding');
    is(refaddr $b, refaddr $binds[$i], '... got the expected binding');

    my $symbol = $b->symbol;
    isa_ok($symbol, 'Allium::Environment::Symbol');

    isnt(refaddr $symbol, refaddr $symbols[$i], '... got the expected (not) symbol');
    is($symbol->name, $symbols[$i]->name, '... got the expected matching symbol name');
    is($symbol->stash_name, 'Bar::', '... got the expected (new) stash name');

    my $value = $b->value;
    isa_ok($value, 'Allium::Environment::Value');

    if ($value isa Allium::Environment::Value::Literal) {
        is($value->literal, $values[$i], '... got the expected (literal) value');
    }
    elsif ($value isa Allium::Environment::Value::Optree) {
        isa_ok($value->optree, 'Allium::Optree');
        is(refaddr $value->optree, refaddr $values[$i], '... got the expected (optree) value');
    }
    else {
        fail("... no idea what value type this is ($value)");
    }
}

done_testing;
