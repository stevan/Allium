
use v5.40;
use experimental qw[ class ];

class Allium::SyntaxTree::ListOp :isa(Allium::SyntaxTree::Expression) {
    field $children :param :reader;

    method accept ($v) {
        $v->visit($self, map { $_->accept($v) } @$children);
    }

    method to_JSON {
        return +{
            $self->SUPER::to_JSON()->%*,
            children => [ map { $_->to_JSON } @$children ]
        }
    }
}
