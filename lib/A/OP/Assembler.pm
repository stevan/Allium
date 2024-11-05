
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

            #warn join ', ' => $old->name, $old, $new;
            if ($old isa Allium::Operation::LOOP) {
                $new->redoop( $self->get( $old->redo_op ) );
                $new->nextop( $self->get( $old->next_op ) );
                $new->lastop( $self->get( $old->last_op ) );
            }
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
        my $op_num  = B::opnumber($op->is_nullified ? 'null' : $op->name);

        my @args;
        if ($opclass eq 'B::COP') {
            @args = ( $op->public_flags->bits, $op_num, undef );
        }
        else {
            #say "op($opclass) -> Found ".B::opnumber($op->{name})." for ".$op->{name};

            @args = ( $op_num, $op->public_flags->bits );

            if ($opclass eq 'B::UNOP') {
                push @args => (
                    ($op->has_first ? $self->get( $op->first ) : undef)
                );
            }
            elsif ($opclass eq 'B::BINOP'  ||
                   $opclass eq 'B::LISTOP' ||
                   $opclass eq 'B::LOOP'   ){
                push @args => (
                    ($op->has_first ? $self->get( $op->first ) : undef),
                    ($op->has_last  ? $self->get( $op->last  ) : undef),
                );
            }
            elsif ($opclass eq 'B::LOGOP') {
                push @args => (
                    ($op->has_first ? $self->get( $op->first ) : undef),
                    ($op->has_other ? $self->get( $op->other ) : undef),
                );
            }
            # HACK!!!
            elsif ($opclass eq 'B::SVOP' && $op->name eq 'const') {
                push @args => ( int(rand(10)) );
            }
            elsif ($opclass eq 'B::SVOP' && $op->name eq 'gv') {
                #my $gv = B::svref_2object(\*main::_);
                #die ">>>>".join '::' => $gv->STASH->NAME, $gv->NAME;
                push @args => ( B::svref_2object(\*main::_) );
                #push @args => ( '*_' );
            }
            elsif ($opclass eq 'B::SVOP' && $op->name eq 'gvsv') {
                push @args => ( '$_' );
            }
            else {
                #warn "GOT: $opclass for ",$op->name;
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
            #elsif ($opclass eq 'B::METHOP') {
            #    # handle meth_sv
            #}
            #elsif ($opclass eq 'B::COP') {
            #    # handle
            #    # - label, stash, stashpv, file, cop_seq,
            #    #   line, warnings, op, hints, hints_hash
            #}
        }

        #warn join ", " => $opclass, @args;

        my $b_op = $opclass->new( @args );
        $b_op->private( $op->private_flags->bits );
        $b_op->targ( $op->pad_target );

        # XXX:
        # B::Generate is kinda trash, it creates LISTOP
        # classes when it is support to be create LOOP
        # classes, because the constructor doesn't check
        # for the inheritance. Probably doesn't matter
        # to the internals of perl, but it does to me
        # (and for completeness).
        bless $b_op => $opclass
            unless blessed $b_op eq $opclass;

        $built{ $op->addr } = $b_op;
        #say join ', ' => $op->type, $op->name, ${ $op }, $op;

        return $b_op;
    }
}


