
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::Environment;
use Allium::Optree;
use Allium::Operations;

class A::OP::Disassembler {
    field $instruction_set :param :reader;

    field %built;
    field $env;
    field $cv;

    method disassemble ($code) {
        # ... clear any previous cache (just in case)
        %built = ();
        # ... and create a new environment and CV
        $env = Allium::Environment->new;
        $cv  = B::svref_2object($code);

        my $root  = $self->get($cv->ROOT);
        my $start = $self->get($cv->START);

        my $optree = Allium::Optree->new(
            root  => $root,
            start => $start,
            env   => $env,
        );

        # ... clear any accumulated cache
        %built = ();
        $env   = undef;
        $cv    = undef;
        # end clearing of accumulated cache ...

        return $optree;
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
                addr          => ${ $b },
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

        $self->process_op_specific_data( $b, $op ) unless $op->is_nullified;

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
            $op->label      = $b->label;            # string
            $op->stash      = $b->stash->NAME;      # STASH
            $op->file       = $b->file;             # string
            $op->cop_seq    = $b->cop_seq;          # number
            $op->line       = $b->line;             # number
            $op->warnings   = $b->warnings->PV;     # B::PV
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

    method build_svop ($b, $op) {
        my $sv = $b->sv;
        my $gv = $b->gv;

        if (${${sv}} == ${${gv}}) {
            if ($sv isa 'B::GV') {
                $op->binding = $env->bind_symbol(
                    $env->parse_symbol(
                        '*'.(join '::' => $sv->STASH->NAME, $sv->NAME)
                    )
                );
            }
            else {
                $op->binding = $env->bind_value(
                    $env->wrap_literal(
                        $sv isa B::IV ? $sv->int_value :
                        $sv isa B::NV ? $sv->NV        :
                        $sv isa B::PV ? $sv->PV        :
                            die "Currently unable to handle sv($sv)"
                    )
                );
            }
        }
        else {
            die "SV and GV are different: ${${sv}} != ${${gv}}";
        }
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
