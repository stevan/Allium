#!perl

use v5.40;

our $SCALAR;
our @ARRAY;
state %HASH = (x => 1);

sub sub_005 {
    return $SCALAR, @ARRAY, %HASH;
}
