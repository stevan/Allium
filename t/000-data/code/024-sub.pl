#!perl

use v5.40;

sub sub_024 {
    my $x = 100;
    my $y = 30;
    my $z;
    $x and $z = 200;
    $y or  $z = 5000;
    $z = ($x and 5) or ($y and 16);
}
