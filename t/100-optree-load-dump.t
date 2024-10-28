#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;
use Allium::Optree::Dumper;
use Allium::Optree::Loader;

sub foo {
    my $x = 10;
    my $y = $x + 100;
}


my $orig = A->new->disassemble(\&foo);
isa_ok($orig, 'Allium::Optree');

my $dump1 = Allium::Optree::Dumper->new->dump($orig);
my $copy  = Allium::Optree::Loader->new->load($dump1);
isa_ok($copy, 'Allium::Optree');

my $dump2 = Allium::Optree::Dumper->new->dump($copy);

isa_ok($orig, 'Allium::Optree');
isa_ok($copy, 'Allium::Optree');
is($orig->root->addr, $copy->root->addr, '... the roots are identical');
is($orig->start->addr, $copy->start->addr, '... the starts are identical');
eq_or_diff($dump1, $dump2, '... the op dumps are identical');

done_testing;
