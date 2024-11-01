
use v5.40;
use experimental qw[ class ];

use B ();
use B::Generate ();

class A::OP::Assembler {
    field $instruction_set :param :reader;

    field %built;

    sub __empty_sub_to_clone {}

    method assemble ($optree) {
        %built = (); # clear any previous cache

        # build all the ops ...
        my @ops;
        $optree->walk(top_down => sub ($op) {
            push @ops => $op, $self->get( $op )
        });

        # connect the next/sibling pointers ...
        foreach my ($old, $new) (@ops) {
            $new->next    ( $self->get( $old->next    )) if $old->has_next;
            $new->sibling ( $self->get( $old->sibling )) if $old->has_sibling;
        }

        # now extract the root & start
        my $root  = $self->get( $optree->root  );
        my $start = $self->get( $optree->start );

        my $sub = B::svref_2object(\&__empty_sub_to_clone)->NEW_with_start (
            $root,
            $start
        )->object_2svref;

        return $sub;
    }

    method get ($op) {
        return $built{ $op->addr } if exists $built{ $op->addr };

        my $opclass = 'B::'.$op->type;
        my $op_num  = B::opnumber($op->name);

        my @args;
        if ($opclass eq 'B::COP') {
            @args = ( $op->public_flags->bits, $op_num, undef );
        }
        else {
            #say "op($opclass) -> Found ".B::opnumber($op->{name})." for ".$op->{name};

            @args = ( $op_num, $op->public_flags->bits );

            if ($opclass eq 'B::UNOP') {
                push @args => ( $self->get( $op->first ) );
            }
            elsif ($opclass eq 'B::BINOP' || $opclass eq 'B::LISTOP') {
                push @args => (
                    $self->get( $op->first ),
                    $self->get( $op->last )
                );
            }
            elsif ($opclass eq 'B::LOGOP') {
                push @args => (
                    $self->get( $op->first ),
                    $self->get( $op->other )
                );
            }
            # HACK!!!
            elsif ($opclass eq 'B::SVOP' && $op->name eq 'const') {
                push @args => ( int(rand(10)) );
            }
            #elsif ($opclass eq 'B::SVOP') {
            #    # handle sv, and gv
            #}
            #elsif ($opclass eq 'B::PADOP') {
            #    # handle padix
            #}
            #elsif ($opclass eq 'B::PVOP') {
            #    # handle pv
            #}
            #elsif ($opclass eq 'B::LOOP') {
            #    # handle redoop, nextop, lastop
            #}
            #elsif ($opclass eq 'B::METHOP') {
            #    # handle meth_sv
            #}
            #elsif ($opclass eq 'B::COP') {
            #    # handle
            #    # - label, stash, stashpv, file, cop_seq,
            #    #   line, warnings, op, hints, hints_hash
            #}
        }

        my $b_op = $opclass->new( @args );
        $b_op->private( $op->private_flags->bits );
        $b_op->targ( $op->pad_target );

        $built{ $op->addr } = $b_op;
        #say join ', ' => $op->type, $op->name, ${ $op }, $op;

        return $b_op;
    }
}


