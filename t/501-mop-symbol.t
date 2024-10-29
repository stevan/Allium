#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use Allium::MOP::Symbol;

my $SYMBOL = '$Foo::Bar::Baz';
my $OTHER  = '@Foo::Bar::Baz';

my $sym = Allium::MOP::Symbol->new( symbol => $SYMBOL );
isa_ok($sym, 'Allium::MOP::Symbol');

is($sym->type, $sym->SCALAR, '... got the expected type');
is($sym->sigil, '$', '... got the expected sigil');
is($sym->namespace, 'Foo::Bar::', '.. got the expected namespace');
is($sym->name, 'Baz', '... got the expected name');

eq_or_diff([ $sym->path ], [ 'Foo::', 'Bar::', 'Baz' ], '... got the path');
eq_or_diff([ $sym->decompose ], [ '$', 'Foo::', 'Bar::', 'Baz' ], '... got the decompose');

is($sym->symbol, $SYMBOL, '... got the expected symbol');

my $sym2 = $sym->copy_as($sym->ARRAY);
isa_ok($sym2, 'Allium::MOP::Symbol');

is($sym2->type, $sym2->ARRAY, '... got the expected type');

is($sym2->symbol, $OTHER, '... got the expected (other) symbol');

done_testing;
