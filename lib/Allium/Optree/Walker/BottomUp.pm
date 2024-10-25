
use v5.40;
use experimental qw[ class ];

class Allium::Optree::Walker::BottomUp :isa(Allium::Optree::Walker) {
    field $f :param :reader;

    method walk ($op) {
        if ($op->has_descendents) {
            for (my $child = $op->first; $child; $child = $child->sibling) {
                $self->walk($child);
            }
        }
        $f->($op);
    }
}
