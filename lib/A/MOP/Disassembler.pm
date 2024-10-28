
use v5.40;
use experimental qw[ class ];

use B ();

class A::MOP::Disassembler {

    field %seen;

    method walk_namespace ($namespace) {
        no strict 'refs';

        my $ns = \%{ $namespace };

        my @symbols;
        foreach my $name ( sort { $a cmp $b } keys %$ns ) {
            my $symbol = *{ $namespace . B::safename($name) };

            if ($name =~ /\:\:$/) {
                next if exists $seen{ $symbol };
                $seen{ $symbol }++;
                push @symbols => $self->walk_namespace( $symbol );
            }
            else {
                push @symbols => $self->dump_symbol( $symbol );
            }
        }

        return @symbols;
    }

    method dump_symbol ($symbol) {
        my ($namespace, $name) = ($symbol =~ /^\*(.*)\:\:([A-Za-z_][A-Za-z0-9_]+)$/);
        unless ($namespace && $name) {
            ($namespace, $name) = ($symbol =~ /^\*(.*)\:\:(\(.+)$/);
        }

        unless ($namespace && $name) {
            die $symbol;
        }

        my @symbols;
        foreach my ($sigil, $SLOT) ('$', 'SCALAR', '@', 'ARRAY', '%', 'HASH', '&', 'CODE') {
            my $slot = *{ $symbol }{ $SLOT };
            next unless defined $slot;
            next if $SLOT eq 'SCALAR' && not defined $$slot; # *sigh* Package::Stash flashbacks
            push @symbols => "${sigil}${namespace}::${name}";
        }

        return @symbols;

    }
}

