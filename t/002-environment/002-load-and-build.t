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

my $symbol1 = $env->parse_symbol('$Foo::BAR');
my $symbol2 = $env->parse_symbol('&Foo::foo');
my $symbol3 = $env->parse_symbol('&Foo::bar');

my $bind1 = $env->bind( $symbol1, $env->wrap_literal('BAR!!') );
my $bind2 = $env->bind( $symbol2, $env->wrap_optree($foo) );
my $bind3 = $env->bind( $symbol3, $env->wrap_optree($bar) );

isa_ok($bind1, 'Allium::Environment::Binding');
isa_ok($bind2, 'Allium::Environment::Binding');
isa_ok($bind3, 'Allium::Environment::Binding');

my @binds  = ($bind1, $bind2, $bind3);
my @symbols = ($symbol1, $symbol2, $symbol3);
my @values = ('BAR!!', $foo, $bar);

my @bindings = $env->bindings;
is(scalar(@bindings), 3, '... we got 3 bindings');

foreach my ($i, $b) (indexed @bindings) {
    isa_ok($b, 'Allium::Environment::Binding');
    is(refaddr $b, refaddr $binds[$i], '... got the expected binding');

    my $symbol = $b->symbol;
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is(refaddr $symbol, refaddr $symbols[$i], '... got the expected symbol');

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
