
use v5.40;
use experimental qw[ class ];

class Allium::Optree::Walker::BottomUp :isa(Allium::Optree::Walker) {
    field $f :param :reader;

    method walk ($op) {
        if ($op->has_descendents) {
            my @children;
            for (my $child = $op->first; $child; $child = $child->sibling) {
                push @children => $child;
            }
            $self->walk($_) foreach reverse @children;
        }
        $f->($op);
    }
}
