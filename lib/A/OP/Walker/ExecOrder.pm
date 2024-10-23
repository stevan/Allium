
use v5.40;
use experimental qw[ class ];

class A::OP::Walker::ExecOrder :isa(A::OP::Walker) {
    field $f :param :reader;

    method walk ($op) {
        my $next = $op;
        while ($next) {
            $f->($next);
            $next = $next->next;
        }
    }
}
