
use v5.40;
use experimental qw[ class ];

# TODO: remove this dependency
use importer 'Path::Tiny' => qw[ path ];

use B::Op_private;

use Allium::InstructionSet::Loader;

class Allium::InstructionSet::Loader::FromPerlCheckout {
    field $perl_checkout :param :reader;
    field $data_directory :param :reader;

    field @opcodes;
    field %name_to_idx;

    ## ---------------------------------------------------------------------------------------------
    ## COPIED FROM regen/opcode.pl and modified slightly
    ## ---------------------------------------------------------------------------------------------

    my %regen_opcode_arg_types = (
        'S'     => 'Scalar',
        'S<'    => 'Numeric',
        'S|'    => 'Binary',
        'C'     => 'Code',
        'A'     => 'Array',
        'H'     => 'Hash',
        'R'     => 'Ref',
        'L'     => 'List',
    # not really needed right now ...
        'Fs'    => 'Any',
        'F-'    => 'Any',
        'DF'    => 'Any',
        'F'     => 'Any',
        'F-+'   => 'Any',
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

    #  m | needs stack mark                    | (OA_MARK)
    #  f | needs constant folding              | (OA_FOLDCONST)
    #  s | produces a scalar                   | (OA_RETSCALAR)
    #  i | produces an integer                 | (unused)
    #  t | needs a target                      | (OA_TARGET)
    #  T | target can be in a pad              | (OA_TARGET|OA_TARGLEX)
    #  I | has a corresponding integer version | (OA_OTHERINT)
    #  d | make temp copy in list assignment   | (OA_DANGEROUS)
    #  u | uses $_ if no argument given        | (OA_DEFGV)

    my %regen_opcode_opflags_map = (
        m => 'OA_MARK',
        f => 'OA_FOLDCONST',
        s => 'OA_RETSCALAR',
        t => 'OA_TARGET',
        T => 'OA_TARGET|OA_TARGLEX',
        i => 'OA_RETINT',
        I => 'OA_OTHERINT',
        d => 'OA_DANGEROUS',
        u => 'OA_DEFGV',
    );

    ## ---------------------------------------------------------------------------------------------

    method generate {
        my $perl = path($perl_checkout);
        my $data = path($data_directory);
        $self->parse_opcode_h( $perl->child('opcode.h') );
        $self->parse_regen_opcodes( $perl->child('regen')->child('opcodes') );
        $self->parse_opcode_categories( $data->child('opcode-categories.csv') );
        return Allium::InstructionSet::Loader->new->load( \@opcodes );
    }

    ## ---------------------------------------------------------------------------------------------

    method parse_opcode_categories ($file) {
        my @lines = $file->lines({ chomp => 1 });
        foreach my $line (@lines) {
            my ($name, undef, $category) = split ',' => $line;

            my $idx = $name_to_idx{$name};

            defined $idx || die "Could not find ($name) opcode";

            $opcodes[$idx]->{category} = $category;
        }
    }

    ## ---------------------------------------------------------------------------------------------

    method parse_regen_opcodes ($file) {
        my @lines = $file->lines({ chomp => 1 });

        foreach my ($i, $line) (indexed @lines) {
            next if !$line || $line =~ /^#/;

            my ($name, $desc, undef, $flags, $args) = split(/\t+/, $line);

            my $idx = $name_to_idx{$name};

            defined $idx || die "Could not find ($name) opcode";

            $opcodes[$idx]->{description}     = $desc // '';
            $opcodes[$idx]->{operation_types} = $self->parse_opclass($flags);
            $opcodes[$idx]->{static_flags}    = $self->parse_flags($flags);
            $opcodes[$idx]->{prototype}       = $self->parse_args($args // '');
            $opcodes[$idx]->{private_flags}   = $self->extract_private_flags($name);
        }
    }

    method extract_private_flags ($name) {
        return $B::Op_private::bits{$name} // +{}
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
