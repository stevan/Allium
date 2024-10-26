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

$tree->walk(top_down  => sub ($op) {
    say(('    ' x $op->depth), sprintf "%s(%s)[%d]" => $op->type, $op->name, $op->addr);
});

done_testing;
