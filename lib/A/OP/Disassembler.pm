
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::Optree;
use Allium::Operations;
use Allium::Pad;
use Allium::Sequence;

class A::OP::Disassembler {
    field $instruction_set :param :reader;

    field %built;

    field $cv;

    field $op_seq;
    field $st_seq;

    method disassemble ($code) {
        # ... clear any previous cache (just in case)
        %built = ();
        # ... and create a new environment and CV
        $cv = B::svref_2object($code);

        $op_seq = Allium::Sequence::Translation->new( sequence => Allium::Sequence::OpAddress->new );
        $st_seq = Allium::Sequence::Translation->new( sequence => Allium::Sequence::Statement->new );

        my $root  = $self->get($cv->ROOT);
        my $start = $self->get($cv->START);

        my $optree = Allium::Optree->new(
            root   => $root,
            start  => $start,
            pad    => $self->get_pad( $cv ),
            op_seq => $op_seq,
            st_seq => $st_seq,
        );

        # ... clear any accumulated cache
        %built  = ();
        $cv     = undef;
        $op_seq = undef;
        $st_seq = undef;
        # end clearing of accumulated cache ...

        return $optree;
    }

    method get_pad ($cv) {
        my $pad = Allium::Pad->new;
        foreach my $entry ($cv->PADLIST->NAMES->ARRAY) {
            $pad->add_entry( $self->process_pad_entry( $entry ) );
        }
        return $pad;
    }

    method process_pad_entry ($entry) {
        my $flags = $self->build_pad_flags( $entry );

        my %args = (
            name      => $entry->PVX,
            flags     => $flags,
            cop_range => $st_seq->translate_range(
                $entry->COP_SEQ_RANGE_HIGH  || 0,
                $entry->COP_SEQ_RANGE_LOW   || 0,
            )
        );

        my $entry_class = 'Allium::Pad::Entry::';
        if ($flags->is_our) {
            $entry_class .= 'Our';
            $args{stash_name} = $entry->OURSTASH->NAME;
        }
        elsif ($flags->is_outer) {
            $entry_class .= 'Outer';
            $args{parent_pad_index} = $entry->PARENT_PAD_INDEX;
            $args{parent_lex_flags} = $self->build_parent_lex_flags( $entry->PARENT_FAKELEX_FLAGS );
        }
        elsif ($flags->is_state) {
            $entry_class .= 'State';
        }
        elsif ($flags->is_lvalue) {
            $entry_class .= 'LValue';
        }
        elsif ($flags->is_field) {
            $entry_class .= 'Field';
        }
        elsif ($flags->is_temp) {
            $entry_class .= 'Temp';
        }
        elsif ($flags->bits == 0) {
            $entry_class .= 'Local';
        }
        else {
            use Data::Dumper;
            die "WTF! ". Dumper([ $entry->PVX, $flags->dump_flags ]);
        }

        return $entry_class->new( %args );
    }

    method get ($b) {
        return undef if $b isa B::NULL;

        return $built{ ${$b} } if exists $built{ ${$b} };

        my $is_null = $b->name eq 'null';
        my $name    = $is_null ? substr(B::ppname( $b->targ ), 3) : $b->name;
        my $opcode  = $instruction_set->get($name);

        my $operation = B::class($b);

        # FIXME:
        # This is all a bit hacky, should be
        # cleaned up and moved to a method
        if ($is_null && $name ne 'null') {
            my @operations = $opcode->operation_types->@*;
            #say "Checking for type for NULLified op($name) - got($operation) have(".(join ', ' => @operations).")";
            if ((scalar @operations) == 1) {
                if ($operation ne $operations[0]) {
                    #say ";;;; ($operation) ne (".($operations[0]).")";
                    $operation = $operations[0];
                }
            }
            else {
                # NOTE:
                # this is likely inadequate, but we will see
                # if it every becomes an issue.
                #die "unable to find a match for ($operation) in (".(join ', ' => @operations).")"
                #    unless scalar grep { $operation eq $_ } @operations;
            }
        }

        my $op = Allium::Operations->build(
            $operation => (
                name          => $name,
                addr          => $op_seq->translate( ${$b} ),
                is_nullified  => $is_null,
                is_optimized  => ($b->opt ? true : false),
                pad_target    => $b->targ,
                public_flags  => $self->build_public_flags($b),
                private_flags => $self->build_private_flags($b),
            )
        );

        $built{ ${$b} } = $op;

        $op->next    = $self->get($b->next)    unless $b->next    isa B::NULL;
        $op->sibling = $self->get($b->sibling) unless $b->sibling isa B::NULL;

        $op->first = $self->get($b->first) if $b isa B::UNOP;
        $op->last  = $self->get($b->last)  if $b isa B::BINOP;
        $op->other = $self->get($b->other) if $b isa B::LOGOP;

        $op->parent = $self->get($b->parent);

        return $op if $op->is_nullified;

        $self->process_op_specific_data( $b, $op );

        return $op;
    }

    method process_op_specific_data ($b, $op) {
        if ($op isa Allium::Operation::LISTOP) {
            $op->num_children = $b->children if $b->can('children');
        }

        if ($op isa Allium::Operation::LOOP) {
            $op->redo_op = $self->get( $b->redoop );
            $op->next_op = $self->get( $b->nextop );
            $op->last_op = $self->get( $b->lastop );
        }

        if ($op isa Allium::Operation::PVOP) {
            $op->pv = B::perlstring($b->pv);
        }

        if ($op isa Allium::Operation::COP) {
            $op->cop_seq    = $st_seq->translate($b->cop_seq);
            # and the other stuff ...
            $op->label      = $b->label;            # string
            $op->stash      = $b->stash->NAME;      # STASH
            if ( $b->file =~ /^\(eval \d+\)/) {
                $op->file = '(eval)';
            }
            else {
                $op->file   = $b->file              # string
            }
            $op->line       = $b->line;             # number
            $op->warnings   = $b->warnings->PV if $b->warnings isa B::PV;  # B::PV
            $op->hints      = $b->hints;            # number
            $op->hints_hash = $b->hints_hash->HASH; # B::RHE
            # XXX : ignore this for now
            #$op->io         = $b->io;              # B::SPECIAL
        }

        # XXX : padops seem to only be used in threads??
        if ($op isa Allium::Operation::PADOP) {
            $op->pad_index = $b->padix;
        }

        if ($op isa Allium::Operation::SVOP) {
            $self->build_svop($b, $op);
        }

        if ($op isa Allium::Operation::UNOP_AUX) {
            $self->build_unop_aux($b, $op);
        }
    }

    method build_unop_aux ($b, $op) {
        my @aux_list = $b->aux_list($cv);
        $op->aux_list = [ @aux_list ];
    }

    method convert_special ($sv) {
        my $idx = ${$sv};          # @B::specialsv_name[$$idx]
        return undef if $idx == 0; # Nullsv
        return undef if $idx == 1; # &PL_sv_undef
        return true  if $idx == 2; # &PL_sv_yes
        return false if $idx == 3; # &PL_sv_no
        return die "Cannot convert special (SV*)pWARN_ALL"  if $idx == 4; # (SV*)pWARN_ALL
        return die "Cannot convert special (SV*)pWARN_NONE" if $idx == 5; # (SV*)pWARN_NONE
        return die "Cannot convert special (SV*)pWARN_STD"  if $idx == 6; # (SV*)pWARN_STD
        return 0     if $idx == 7; # &PL_sv_zero
        die "Unknown SPECIAL($idx)";
    }

    method build_svop ($b, $op) {
        my $sv = $b->sv;
        if ($sv isa B::GV) {
            #say '!!!!!!!!!!!', join '::' => $sv->STASH->NAME, $sv->NAME;
        }
    }

    method build_parent_lex_flags ($bits) {
        Allium::Flags::Pad::ParentFlags->new( bits => $bits,
            is_anon  => !! ($bits & B::PAD_FAKELEX_ANON),
            is_multi => !! ($bits & B::PAD_FAKELEX_MULTI),
        )
    }

    method build_pad_flags ($entry) {
        Allium::Flags::Pad::Flags->new( bits => $entry->FLAGS,
            is_outer  => !! ($entry->FLAGS & B::PADNAMEf_OUTER),
            is_state  => !! ($entry->FLAGS & B::PADNAMEf_STATE),
            is_lvalue => !! ($entry->FLAGS & B::PADNAMEf_LVALUE),
            is_our    => !! ($entry->FLAGS & B::PADNAMEf_OUR),
            is_field  => !! ($entry->FLAGS & B::PADNAMEf_FIELD),
            is_temp   => !! ($entry->IsUndef),
        )
    }

    method build_public_flags ($b) {
        Allium::Flags::Operation::PublicFlags->new( bits => $b->flags,
            wants_void         => !! (($b->flags & B::OPf_WANT) == B::OPf_WANT_VOID  ),
            wants_scalar       => !! (($b->flags & B::OPf_WANT) == B::OPf_WANT_SCALAR),
            wants_list         => !! (($b->flags & B::OPf_WANT) == B::OPf_WANT_LIST  ),

            has_descendents    => !! ($b->flags & B::OPf_KIDS   ),
            was_parenthesized  => !! ($b->flags & B::OPf_PARENS ),
            return_container   => !! ($b->flags & B::OPf_REF    ),
            is_lvalue          => !! ($b->flags & B::OPf_MOD    ),
            is_mutator_varient => !! ($b->flags & B::OPf_STACKED),
            is_special         => !! ($b->flags & B::OPf_SPECIAL),
        )
    }

    method build_private_flags ($b) {
        Allium::Flags::Operation::PrivateFlags->new( bits => $b->private,
            introduces_lexical => !! ($b->private & B::OPpLVAL_INTRO),
            has_pad_target     => !! ($b->private & B::OPpTARGET_MY),
        );
    }

}
