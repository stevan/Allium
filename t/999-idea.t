#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use B;
use A;

sub walksymtable ($namespace, $f, $depth=0) {
    state %seen;
    no strict 'refs';

    foreach my $name ( sort { $a cmp $b } keys %{ $namespace } ) {
        my $symbol = *{ $namespace . B::safename($name) };

        $f->($symbol, $depth);

        if ($name =~ /\:\:$/) {
            next if exists $seen{ $symbol };
            $seen{ $symbol }++;
            walksymtable( $symbol, $f, $depth + 1 );
        }
    }
}

walksymtable( *main:: => sub ($symbol, $depth) {
    say(('  ' x $depth),join ', ' => $symbol);
});


done_testing;
