#!perl

use v5.40;

sub sub_027 {
    my $x = 10;
    {
        my $x = 100.5 + $x;
        my $y = 1000;
        $x += $y;
    }
    $x + 5;
}
