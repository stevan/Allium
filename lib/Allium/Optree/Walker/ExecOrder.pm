
use v5.40;
use experimental qw[ class ];

class Allium::Optree::Walker::ExecOrder :isa(Allium::Optree::Walker) {
    field $f :param :reader;

    method walk ($op) {
        my $next = $op;
        while ($next) {
            $f->($next);
            $next = $next->next;
        }
    }
}
