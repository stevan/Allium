#!perl

use v5.40;

sub sub_008 ($name, %opts) {
    my @out;
    foreach my $opt (keys %opts) {
        push @out => "${name} => ${opt}";
    }
    return join ', ' => @out;
}
