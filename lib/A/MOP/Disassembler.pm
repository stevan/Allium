
use v5.40;
use experimental qw[ class ];

use B ();

class A::MOP::Disassembler {

}

sub walksymtable ($symbol) {
    foreach my $glob ( sort { $a cmp $b } keys %{ $symbol } ) {
        warn $glob;
    }
}
