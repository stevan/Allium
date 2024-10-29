
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::MOP;

class A::MOP::Disassembler {

    field $mop :reader;

    field %already_crawled;

    ADJUST {
        $mop = Allium::MOP->new;
    }

    method disassemble ($namespace) {
        my @symbols = $self->collect_all_symbols($namespace);

        my @data;
        foreach my $pack (@symbols) {
            my ($symbol, $data) = @$pack;

            my $value = $mop->autovivify( $symbol );
            push @data => +{ $value->OID, $data };
        }

        return \@data, $mop;
    }

    method collect_all_symbols ($namespace) {
        no strict 'refs';

        my $ns = \%{ $namespace };

        my @symbols;
        foreach my $name ( sort { $a cmp $b } keys %$ns ) {
            my $glob = *{ $namespace . B::safename($name) };

            if ($name =~ /\:\:$/) {
                next if exists $already_crawled{ $glob };
                $already_crawled{ $glob }++;
                push @symbols => $self->collect_all_symbols( $glob );
            }
            else {
                push @symbols => $self->dump_glob_symbols( $glob );
            }
        }

        return @symbols;
    }

    method dump_glob_symbols ($glob) {
        my $symbol = $mop->new_symbol( $glob );

        #say "FOOO!!!! ", join ", " => $symbol->decompose;

        my @symbols;
        foreach my ($sigil, $SLOT) (%Allium::MOP::Symbol::SIGIL_TO_SLOT) {
            my $slot = *{ $glob }{ $SLOT };
            next unless defined $slot;
            next if $SLOT eq 'SCALAR' && not defined $$slot; # *sigh* Package::Stash flashbacks
            # FIXME:
            # this ignores variables you declared but
            # did not set yet, so we need to figure
            # out how to handle that. In most cases
            # `perl` will do the right thing anyway,
            # but we are interested in compile time
            # data, so need to check.
            #
            # NOTE:
            # Package::Stash will know how to do it ;)

            push @symbols => [
                $symbol->copy_as($SLOT),
                ($SLOT eq 'SCALAR' ? $$slot : $slot)
            ];
        }

        return @symbols;
    }
}

