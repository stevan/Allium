
use v5.40;
use experimental qw[ class ];

class Allium::SyntaxTree::Statement :isa(Allium::SyntaxTree::Node) {
    #field $expression :param :reader;
    #method accept ($v) {
    #    $v->visit($self, $expression->accept($v));
    #}
}
