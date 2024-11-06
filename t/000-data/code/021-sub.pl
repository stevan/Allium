#!perl

use v5.40;

sub sub_021 {
    my $x = "foo";
    my $y = "bar";
    my $z;
    $z = $x && $y;
    $z = $x || $y;
    $z = $x // $y;
    $z = ($x // "bar") && ($y || "foo");
}
