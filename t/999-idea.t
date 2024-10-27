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

sub pprint ($op) {
    say($op->addr,'->',('  ' x $op->depth),join ':' => $op->type, $op->name)
}

my $orig = A->new->disassemble(\&foo);
$orig->walk(top_down => \&pprint);

done_testing;
