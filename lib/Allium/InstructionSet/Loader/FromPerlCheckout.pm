
use v5.40;
use experimental qw[ class ];

# TODO: remove this dependency
use importer 'Path::Tiny' => qw[ path ];

use Allium::InstructionSet::Loader;

class Allium::InstructionSet::Loader::FromPerlCheckout {
    field $perl_checkout :param :reader;

    field @opcodes;
    field %name_to_idx;

    ## ---------------------------------------------------------------------------------------------
    ## COPIED FROM regen/opcode.pl and modified slightly
    ## ---------------------------------------------------------------------------------------------

    my %regen_opcode_arg_types = (
        'S'     => 'SCALAR',
        'H'     => 'HASH',
        'S<'    => 'NUMERIC',
        'L'     => 'LIST',
        'C'     => 'CODE',
        'A'     => 'ARRAY',
        'R'     => 'REF',
        'S|'    => 'BINARY',
    # not really needed right now ...
        'Fs'    => 'SOCKET',
        'F-'    => 'FILETEST',
        'DF'    => 'DIR',
        'F'     => 'FILE',
        'F-+'   => 'FILETEST_ACCESS',
    );

    my %regen_opcode_opclass_map = (
        '0' => [ 'OP',           ], # baseop
        '1' => [ 'UNOP',         ], # unop
        '%' => [ 'OP', 'UNOP'    ], # baseop_or_unop
        '2' => [ 'BINOP',        ], # binop
        '|' => [ 'LOGOP',        ], # logop
        '@' => [ 'LISTOP',       ], # listop
        '/' => [ 'PMOP',         ], # pmop
        '$' => [ 'SVOP', 'PADOP' ], # svop_or_padop
        '#' => [ 'PADOP',        ], # padop
        '"' => [ 'PVOP', 'SVOP'  ], # pvop_or_svop
        '{' => [ 'LOOP',         ], # loop
        ';' => [ 'COP',          ], # cop
        '.' => [ 'METHOP',       ], # methop
        '+' => [ 'UNOP_AUX',     ], # unop_aux
        '}' => [ 'LOOPEXOP',     ], # loopexop
        '-' => [ 'FILESTAT_OP',  ], # filestat_op
    );

    my %regen_opcode_opflags_map = (
        m => 'needs_stack_mark',
        f => 'fold_constants',
        s => 'always_produces_scalar',
        t => 'needs_target_scalar',
        T => 'needs_target_scalar_which_may_be_lexical',
        i => 'always_produces_integer',
        I => 'has_corresponding_int_op',
        d => 'danger_make_temp_copy_in_list_assignment',
        u => 'defaults_to_topic',
    );

    ## ---------------------------------------------------------------------------------------------

    method generate {
        my $perl = path($perl_checkout);
        $self->parse_opcode_h( $perl->child('opcode.h') );
        $self->parse_regen_opcodes( $perl->child('regen')->child('opcodes') );
        return Allium::InstructionSet::Loader->new->load( \@opcodes );
    }

    ## ---------------------------------------------------------------------------------------------

    method parse_regen_opcodes ($file) {
        my @lines = $file->lines({ chomp => 1 });

        foreach my ($i, $line) (indexed @lines) {
            next if !$line || $line =~ /^#/;

            my ($name, $desc, undef, $flags, $args) = split(/\t+/, $line);

            my $idx = $name_to_idx{$name};

            $opcodes[$idx]->{desc}       = $desc if $desc;
            $opcodes[$idx]->{opclass}    = $self->parse_opclass($flags);
            $opcodes[$idx]->{flags}      = $self->parse_flags($flags);
            next unless $args;
            $opcodes[$idx]->{args} = $self->parse_args($args);
            # For debugging ... ignored by other tools
            # $opcodes[$idx]->{raw} = +{
            #     args  => $args,
            #     flags => $flags,
            # };
        }
    }

    method parse_flags ($flags) {
        my @flags = split '' => $flags;
        pop @flags; # discard the opclass
        return [] unless @flags;
        #say "FLAGS: ",join ', ' => map { $_ // '~' } @flags;
        my @opts = @regen_opcode_opflags_map{ @flags };
        #say "OPTS: ",join ", " => map { $_ // '~' } @opts;
        return \@opts;
    }

    method parse_args ($args) {
        my @out;
        my @args = split /\s+/ => $args;
        foreach my $arg (@args) {
            my $opt = false;
            if ($arg =~ /\?$/) {
                $arg =~ s/\?$//;
                $opt = true;
            }
            push @out => +{
                type     => $regen_opcode_arg_types{$arg},
                optional => ($opt ? 1 : 0)
            };
        }
        return \@out;
    }

    method parse_opclass ($flags) {
        #warn "FLAGS: $flags";
        my @flags = split '' => $flags;
        #warn "\@FLAGS: ",join ', ' => @flags;
        my $opclass = pop @flags;
        return unless exists $regen_opcode_opclass_map{$opclass};
        return $regen_opcode_opclass_map{$opclass}
    }

    ## ---------------------------------------------------------------------------------------------

    method parse_opcode_h ($file) {
        state $START = 'EXTCONST char* const PL_op_name[] INIT({';
        state $STOP  = '});';

        my @lines = $file->lines({ chomp => 1 });

        my $in;
        my $idx = 0;
        foreach my ($i, $line) (indexed @lines) {
            if (not defined $in) {
                next unless $line eq $START;
                $in = true;
                next; # skip the $START line
            }

            if ($in) {
                if ($line ne $STOP) {
                    my ($name) = $line =~ /\s*\"(.*)\"\,/;
                    $opcodes[$idx] = +{ name  => $name };
                    $name_to_idx{ $name } = $idx;
                    $idx++;
                }
                else {
                    last;
                }
            }
        }

        # we don't need this one ...
        pop @opcodes if $opcodes[-1]->{name} eq 'freed';

        return;
    }


}
