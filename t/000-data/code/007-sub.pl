#!perl

use v5.40;

sub sub_007 {
    my $x     = 0;
    my @array = (1 .. 10);

    foreach my $y (@array) {
        $x += $y;
    }
}
