
use v5.40;
use experimental qw[ class ];

use A::OP::Walker::TopDown;
use A::OP::Walker::BottomUp;
use A::OP::Walker::ExecOrder;

class A::OP::Unit {
    field $root  :param :reader;
    field $start :param :reader;

    method walk ($mode, $f) {
        return A::OP::Walker::TopDown   ->new( f => $f )->walk( $root  ) if $mode eq 'top_down';
        return A::OP::Walker::BottomUp  ->new( f => $f )->walk( $root  ) if $mode eq 'bottom_up';
        return A::OP::Walker::ExecOrder ->new( f => $f )->walk( $start ) if $mode eq 'exec';
        die "Unknown walk mode($mode)";
    }
}

