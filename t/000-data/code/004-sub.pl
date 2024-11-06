#!perl

use v5.40;

sub sub_004 ($x) {
    if ($x > 5) {
        my $y = 1000;
    }
    else {
        my $y = 1300;
        my $z = cos($y + $x);
        my @test = (1 .. 100);
    }
}
