#!perl

use v5.40;

sub sub_022 {
    my $x = 100;
    my $y = 204;
    my $z;
    $z = $x && $y;
    $z = $x || $y;
    $z = $x // $y;
    $z = ($x // 5) && ($y || 16);
}
