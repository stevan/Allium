#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use A;

sub foo ($x) {
    if ($x > 5) {
        my $y = 1000;
    }
    else {
        my $y = 1300;
        my $z = cos($y + $x);
        my @test = (1 .. 100);
    }
}

my $tree = A->new->disassemble(\&foo);
isa_ok($tree, 'Allium::Optree');

my (@top_down, @bottom_up);
$tree->walk(top_down  => sub ($op) { push @top_down  => $op });
$tree->walk(bottom_up => sub ($op) { push @bottom_up => $op });

eq_or_diff(
    [ map $_->addr, @top_down ],
    [ map $_->addr, reverse @bottom_up ],
    '... top-down <-> bottom_up works'
);

done_testing;
