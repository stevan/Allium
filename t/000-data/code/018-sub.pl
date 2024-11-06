#!perl

use v5.40;

sub sub_018 {
    my $x = "foo";
    my $y = "bar";
    my $z = $x . "test" . $y . "baz" . $x;
    $y = $x . "test";
    $z .= $x . "test" . $y;
    my $r = "test" . $y . "bar" . $z . $x;
}
