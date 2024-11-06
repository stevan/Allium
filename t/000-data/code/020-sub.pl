#!perl

use v5.40;

sub sub_020 {
    my $x = "foo";
    my $y = "bar";
    my $z;
    $z = $x eq $y;
    $z = $x ne $y;
    $z = $x lt $y;
    $z = $x le $y;
    $z = $x gt $y;
    $z = $x ge $y;
}
