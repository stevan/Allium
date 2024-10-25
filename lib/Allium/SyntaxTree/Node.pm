
use v5.40;
use experimental qw[ class ];

class Allium::SyntaxTree::Node {
    field $op  :param :reader;

    field $id        :reader;
    field $node_type :reader;
    field $name      :reader;

    my $ID_SEQ = 0;
    ADJUST {
        $id        = ++$ID_SEQ;
        $node_type = __CLASS__ =~ s/Allium::SyntaxTree:://r;
        $name      = sprintf '%s[%d](%s)' => $node_type, $id, $op->name;
    }

    method accept ($v) { $v->visit($self) }

    method to_JSON {
        return +{
            __id        => $id,
            __name      => $name,
            __node_type => $node_type,
            __opcode    => $op->name,
        }
    }
}
