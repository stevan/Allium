
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::Environment;
use Allium::MOP;

class A::MOP::Disassembler {
    field $op_disassembler :param :reader;

    field %already_crawled;

    my %SIGIL_TO_SLOT = (
        '$' => 'SCALAR',
        '@' => 'ARRAY',
        '%' => 'HASH',
        '&' => 'CODE',
        # I am not dealing with globs here,
        # so we can ignore them (for now)
    );

    method disassemble ($namespace) {
        %already_crawled = (); # clear any previous cache

        my $env = $self->collect_all_symbols(
            Allium::Environment->new,
            $namespace
        );

        return Allium::MOP->new->load_environment( $env );
    }

    method collect_all_symbols ($env, $namespace) {
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
                $self->collect_all_symbols( $env, $glob );
            }
            else {
                $self->process_glob_symbols( $env, $glob );
            }
        }

        return $env;
    }

    method process_glob_symbols ($env, $glob) {
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

