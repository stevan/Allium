
use v5.40;
use experimental qw[ class ];

use Allium::SyntaxTree::Node;
use Allium::SyntaxTree::Statement;
use Allium::SyntaxTree::Expression;
use Allium::SyntaxTree::UnOp;
use Allium::SyntaxTree::BinOp;
use Allium::SyntaxTree::ListOp;

class Allium::SyntaxTree {
    field $optree :param :reader;

    method build {
        my ($root) = $optree->root->accept($self);
        return $root;
    }

    method visit ($op, @args) {
        #return $self->visit_loop($op, @args)     if $op isa Allium::Operation::LOOP;
        #return $self->visit_pmop($op, @args)     if $op isa Allium::Operation::PMOP;
        return $self->visit_listop($op, @args)   if $op isa Allium::Operation::LISTOP;
        return $self->visit_binop($op, @args)    if $op isa Allium::Operation::BINOP;
        return $self->visit_logop($op, @args)    if $op isa Allium::Operation::LOGOP;
        #return $self->visit_unop_aux($op, @args) if $op isa Allium::Operation::UNOP_AUX;
        return $self->visit_unop($op, @args)     if $op isa Allium::Operation::UNOP;
        #return $self->visit_methop($op, @args)   if $op isa Allium::Operation::METHOP;
        return $self->visit_cop($op, @args)      if $op isa Allium::Operation::COP;
        #return $self->visit_pvop($op, @args)     if $op isa Allium::Operation::PVOP;
        #return $self->visit_padop($op, @args)    if $op isa Allium::Operation::PADOP;
        #return $self->visit_svop($op, @args)     if $op isa Allium::Operation::SVOP;
        return $self->visit_op($op, @args)       if $op isa Allium::Operation::OP;
        return;
    }

    method visit_loop ($op, @args) {}
    method visit_pmop ($op, @args) {}

    method visit_listop ($op, @args) {
        return Allium::SyntaxTree::ListOp->new(
            op       => $op,
            children => \@args
        );
    }

    method visit_binop ($op, @args) {
        my ($lhs, $rhs) = @args;
        return Allium::SyntaxTree::BinOp->new(
            op  => $op,
            lhs => $lhs,
            rhs => $rhs,
        );
    }

    method visit_logop ($op, @args) {
        my ($lhs, $rhs) = @args;
        return Allium::SyntaxTree::BinOp->new(
            op  => $op,
            lhs => $lhs,
            rhs => $rhs,
        );
    }

    method visit_unop_aux ($op, @args) {}

    method visit_unop ($op, @args) {
        my ($operand) = @args;
        return Allium::SyntaxTree::UnOp->new(
            op      => $op,
            operand => $operand
        );
    }

    method visit_methop ($op, @args) {}

    method visit_cop ($op, @args) {
        return Allium::SyntaxTree::Statement->new( op => $op );
    }

    method visit_pvop ($op, @args) {}
    method visit_padop ($op, @args) {}
    method visit_svop ($op, @args) {}

    method visit_op ($op, @args) {
        return Allium::SyntaxTree::Node->new( op => $op );
    }

}
