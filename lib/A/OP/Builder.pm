
use v5.40;
use experimental qw[ class ];

use B ();

use A::OP::Unit;
use Allium::Operations;

class A::OP::Builder {
    field %built;

    method build ($code) {
        my $cv = B::svref_2object($code);

        my $root  = $self->get($cv->ROOT);
        my $start = $self->get($cv->START);

        return A::OP::Unit->new( root => $root, start => $start );
    }

    method get ($b) {
        return undef if $b isa B::NULL;

        return $built{ ${$b} } if exists $built{ ${$b} };

        my $class = sprintf 'Allium::Operation::%s' => B::class($b);

        my $is_null = $b->name eq 'null';
        my $name    = $is_null ? substr(B::ppname( $b->targ ), 3) : $b->name;

        my $op = $class->new(
            name    => $name,
            desc    => $b->desc,
            addr    => ${ $b },
            type    => B::class($b),
            # ...
            is_null         => $is_null,
            has_descendents => !!($b->flags & B::OPf_KIDS()),
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
}
