
use v5.40;
use experimental qw[ class ];

class Allium::SyntaxTree::UnOp :isa(Allium::SyntaxTree::Expression) {
    field $operand :param :reader;

    method accept ($v) {
        $v->visit($self, $operand->accept($v));
    }

    method to_JSON {
        return +{
            $self->SUPER::to_JSON()->%*,
            operand => $operand->to_JSON,
        }
    }
}
