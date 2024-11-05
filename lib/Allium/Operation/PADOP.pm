
use v5.40;
use experimental qw[ class ];

# XXX : padops seem to only be used in threads??

class Allium::Operation::PADOP :isa(Allium::Operation::OP) {
    field $pad_index;

    method pad_index :lvalue { $pad_index }
}
