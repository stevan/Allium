#!perl

use v5.40;

sub sub_019 {
    my $x = "foo";
    my $y = "bar";
    my $z = $x . ($x . "baz") . $y;
}
