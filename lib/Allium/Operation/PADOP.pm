
use v5.40;
use experimental qw[ class ];

class Allium::Operation::PADOP :isa(Allium::Operation::OP) {
    field $pad_index;

    method pad_index :lvalue { $pad_index }
}
