
use v5.40;
use experimental qw[ class ];

class Allium::Operation::UNOP_AUX :isa(Allium::Operation::UNOP) {
    field $aux_list;

    method aux_list :lvalue { $aux_list }
}
