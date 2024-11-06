#!perl

use v5.40;

sub sub_023 {
    my $x = 100;
    my $y = 2.4;
    my $z;
    $z = $x && $y;
    $z = $x || $y;
    $z = $x // $y;
    $z = ($x // 5) && ($y || 16);
}
