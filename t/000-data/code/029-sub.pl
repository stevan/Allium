#!perl

use v5.40;

sub sub_029 {
    my $x = 100;
    my $y = \$x;
    my $z = $y->$*;
    my $p = $$y;
    $y->$* = 200;
    my $q = $y->$* + $$y;
    $$y = "foo";
}
