#!perl

use v5.40;

sub sub_025 {
    my $x = 100;
    my $y = 30;
    my $z;
    $z = 200  if $x;
    $z = 5000 unless $y;
    ($y and 16) unless $z = ($x and 5);
}
