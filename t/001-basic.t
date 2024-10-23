#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;

use A;

sub foo ($x) {
    if ($x > 5) {
        my $y = 1000;
    }
    else {
        my $y = 1300;
        my $z = cos($y + $x);
    }
}

my $unit = A->new->disassemble(\&foo);

$unit->walk(top_down => sub ($op) {
    say((sprintf '%-80s %20s',
            (sprintf '%8s[%d]%s(%s)%s' =>
                    $op->type,
                    $op->addr,
                    ('  ' x $op->depth),
                    $op->name,
                    ($op->is_null ? '*' : '')),
            (sprintf '-> %10s' =>
                    ($op->next ? $op->next->addr : '(end)'))));
});

done_testing;
