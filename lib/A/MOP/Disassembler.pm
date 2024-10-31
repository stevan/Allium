
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::Environment;

use A::OP::Disassembler;

class A::MOP::Disassembler {
    field $op_disassembler :param :reader;

    field $env :reader;

    field %already_crawled;

    ADJUST {
        $env = Allium::Environment->new;
    }

    my %SIGIL_TO_SLOT = (
        '$' => 'SCALAR',
        '@' => 'ARRAY',
        '%' => 'HASH',
        '&' => 'CODE',
        # I am not dealing with globs here,
        # so we can ignore them (for now)
    );

    method disassemble ($namespace) {
        no strict 'refs';

        my $ns = \%{ $namespace };

        foreach my $name ( sort { $a cmp $b } map { B::safename($_) } keys %$ns ) {
            # NOTE:
            # this is something to look at later
            # but for now, we punt on these things
            next if $name =~ /^(BEGIN|CHECK|INIT|UNITCHECK|END)/;

            my $glob = *{ $namespace . $name };

            #say "visiting ... $glob";

            if ($name =~ /\:\:$/) {
                next if exists $already_crawled{ $glob };
                $already_crawled{ $glob }++;
                $self->collect_all_symbols( $glob );
            }
            else {
                $self->process_glob_symbols( $glob );
            }
        }

        return $env;
    }

    method process_glob_symbols ($glob) {
        #say "processing ... $glob";

        foreach my ($sigil, $SLOT) (%SIGIL_TO_SLOT) {
            my $slot = *{ $glob }{ $SLOT };
            next unless defined $slot;
            # FIXME:
            # this ignores variables you declared but
            # did not set yet, so we need to figure
            # out how to handle that. In most cases
            # `perl` will do the right thing anyway,
            # but we are interested in compile time
            # data, so need to check. Package::Stash
            # will know how to do it ;)
            next if $SLOT eq 'SCALAR' && not defined $$slot; # *sigh* Package::Stash flashbacks

            my $symbol = $glob;
            $symbol =~ s/^\*/$sigil/;

            my $s = $env->parse_symbol($symbol);
            my $v;
            if ($SLOT eq 'CODE') {
                my $optree = $op_disassembler->disassemble($slot);
                #say "......... got optree: $optree for: $slot";
                $v = $env->wrap_optree($optree);
            }
            elsif ($SLOT eq 'ARRAY') {
                $v = $env->wrap_literal([ @$slot ]);
            }
            elsif ($SLOT eq 'HASH') {
                $v = $env->wrap_literal({ %$slot });
            }
            elsif ($SLOT eq 'SCALAR') {
                die "SCALAR REFs are current not supported" if ref $$slot;
                $v = $env->wrap_literal($$slot);
            }

            $env->bind( $s, $v );
        }
    }
}

