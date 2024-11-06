#!perl

use v5.40;

sub sub_033 {
    my $x = 100;
    my $y = "test";
    my $z;
    $z = $x && $y;
    $z = $x || $y;
    $z = $x // $y;
    $z = ($x // 5) && ($y || 16);
}
