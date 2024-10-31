#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use Allium::Environment;

my $env = Allium::Environment->new;
isa_ok($env, 'Allium::Environment');

subtest '... testing scalar symbol' => sub {
    my $symbol = $env->parse_symbol('$Foo::Bar::BAZ');
    isa_ok($symbol, 'Allium::Environment::Symbol::Scalar');
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is($symbol->sigil, '$', '... got the expected sigil');
    is($symbol->name, 'BAZ', '... got the expected name');
    is($symbol->stash_name, 'Foo::Bar::', '... got the expected stash');
};

subtest '... testing array symbol' => sub {
    my $symbol = $env->parse_symbol('@Foo::Bar::BAZ');
    isa_ok($symbol, 'Allium::Environment::Symbol::Array');
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is($symbol->sigil, '@', '... got the expected sigil');
    is($symbol->name, 'BAZ', '... got the expected name');
    is($symbol->stash_name, 'Foo::Bar::', '... got the expected stash');
};

subtest '... testing hash symbol' => sub {
    my $symbol = $env->parse_symbol('%Foo::Bar::BAZ');
    isa_ok($symbol, 'Allium::Environment::Symbol::Hash');
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is($symbol->sigil, '%', '... got the expected sigil');
    is($symbol->name, 'BAZ', '... got the expected name');
    is($symbol->stash_name, 'Foo::Bar::', '... got the expected stash');
};

subtest '... testing code symbol' => sub {
    my $symbol = $env->parse_symbol('&Foo::Bar::BAZ');
    isa_ok($symbol, 'Allium::Environment::Symbol::Code');
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is($symbol->sigil, '&', '... got the expected sigil');
    is($symbol->name, 'BAZ', '... got the expected name');
    is($symbol->stash_name, 'Foo::Bar::', '... got the expected stash');
};

subtest '... testing glob symbol' => sub {
    my $symbol = $env->parse_symbol('*Foo::Bar::BAZ');
    isa_ok($symbol, 'Allium::Environment::Symbol::Glob');
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is($symbol->sigil, '*', '... got the expected sigil');
    is($symbol->name, 'BAZ', '... got the expected name');
    is($symbol->stash_name, 'Foo::Bar::', '... got the expected stash');
};

subtest '... testing glob (stash) symbol' => sub {
    my $symbol = $env->parse_symbol('*Foo::Bar::');
    isa_ok($symbol, 'Allium::Environment::Symbol::Glob');
    isa_ok($symbol, 'Allium::Environment::Symbol');

    is($symbol->sigil, '*', '... got the expected sigil');
    is($symbol->name, 'Bar::', '... got the expected name');
    is($symbol->stash_name, 'Foo::', '... got the expected stash');

    ok($symbol->is_stash, '... this is a stash symbol')
};

subtest '... testing literal' => sub {
    my $value = $env->wrap_literal("Hello World" );
    isa_ok($value, 'Allium::Environment::Value::Literal');

    is($value->literal, 'Hello World', '... got the value we expected');
};

subtest '... testing bind' => sub {
    my $symbol  = $env->parse_symbol('$Foo::Bar::BAZ');
    my $value   = $env->wrap_literal("Hello World" );
    my $binding = $env->bind( $symbol, $value );
    isa_ok($binding, 'Allium::Environment::Binding');

    is(refaddr $symbol, refaddr $binding->symbol, '... got the expected symbol');
    is(refaddr $value,  refaddr $binding->value,  '... got the expected value');
};

done_testing;

