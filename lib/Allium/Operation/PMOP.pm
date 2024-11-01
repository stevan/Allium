
use v5.40;
use experimental qw[ class ];

class Allium::Operation::PMOP :isa(Allium::Operation::LISTOP) {
    field $code_list;
    field $regexp;

    method code_list :lvalue { $code_list }
    method regexp    :lvalue { $regexp    }
}
