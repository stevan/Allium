
use v5.40;
use experimental qw[ class ];

use B ();

use Allium::Optree;
use Allium::Operations;

class A::OP::Disassembler {
    field $instruction_set :param :reader;

    field %built;

    method disassemble ($code) {
        %built = (); # clear any previous cache

        my $cv = B::svref_2object($code);

        my $root  = $self->get($cv->ROOT);
        my $start = $self->get($cv->START);

        return Allium::Optree->new( root => $root, start => $start );
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
                    #say "($operation) ne (".($operations[0]).")";
                    $operation = $operations[0];
                }
            }
            else {
                # NOTE:
                # this is likely inadequate, but we will see
                # if it every becomes an issue.
                die "unable to find a match for ($operation) in (".(join ', ' => @operations).")"
                    unless scalar grep { $operation eq $_ } @operations;
            }
        }

        my $op = Allium::Operations->build(
            $operation => (
                name          => $name,
                addr          => ${ $b },
                is_nullified  => $is_null,
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

        return $op;
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
