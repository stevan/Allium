#!perl

use v5.40;

sub sub_034 {
    my @array;
    @array = (10, 20, 30);
    $array[10] = 300;
    my $x = $array[3];
    my @foo = (1, @array, 10, $x);
}
