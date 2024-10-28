
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::MOP;

class A::MOP::Disassembler {

    field %seen;

    method disassemble ($namespace) {
        my @symbols = $self->collect_all_symbols($namespace);
        my $mop = Allium::MOP->new;
        foreach my $symbol (@symbols) {
            $mop->autovivify( $symbol );
        }
        return $mop;
    }

    method collect_all_symbols ($namespace) {
        no strict 'refs';

        my $ns = \%{ $namespace };

        my @symbols;
        foreach my $name ( sort { $a cmp $b } keys %$ns ) {
            my $glob = *{ $namespace . B::safename($name) };

            if ($name =~ /\:\:$/) {
                next if exists $seen{ $glob };
                $seen{ $glob }++;
                push @symbols => $self->collect_all_symbols( $glob );
            }
            else {
                push @symbols => $self->dump_glob_symbols( $glob );
            }
        }

        return @symbols;
    }

    method dump_glob_symbols ($glob) {
        my ($namespace, $name) = ($glob =~ /^\*(.*)\:\:([A-Za-z_][A-Za-z0-9_]+)$/);
        unless ($namespace && $name) {
            ($namespace, $name) = ($glob =~ /^\*(.*)\:\:(\(.+)$/);
        }

        unless ($namespace && $name) {
            die "WTF! -> $glob";
        }

        my @symbols;
        foreach my ($sigil, $SLOT) ('$', 'SCALAR', '@', 'ARRAY', '%', 'HASH', '&', 'CODE') {
            my $slot = *{ $glob }{ $SLOT };
            next unless defined $slot;
            next if $SLOT eq 'SCALAR' && not defined $$slot; # *sigh* Package::Stash flashbacks
            push @symbols => "${sigil}${namespace}::${name}";
        }

        return @symbols;
    }
}

