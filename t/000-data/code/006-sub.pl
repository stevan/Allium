#!perl

use v5.40;

sub sub_006 {
    state $x = 10;
    my $z = $x + 10;
}
