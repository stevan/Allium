
use v5.40;
use experimental qw[ class ];

use A::OP::Builder;

class A {

    method disassemble ($code) {
        return A::OP::Builder->new->build($code);
    }
}
