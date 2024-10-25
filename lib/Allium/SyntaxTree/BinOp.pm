
use v5.40;
use experimental qw[ class ];

class Allium::SyntaxTree::BinOp :isa(Allium::SyntaxTree::Expression) {
    field $lhs :param :reader;
    field $rhs :param :reader;

    method accept ($v) {
        $v->visit($self, $lhs->accept($v), $rhs->accept($v));
    }

    method to_JSON {
        return +{
            $self->SUPER::to_JSON()->%*,
            lhs => $lhs->to_JSON,
            rhs => $rhs->to_JSON,
        }
    }
}
