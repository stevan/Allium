
use v5.40;
use experimental qw[ class ];

use Allium::Optree::Walker::TopDown;
use Allium::Optree::Walker::BottomUp;
use Allium::Optree::Walker::ExecOrder;

class Allium::Optree {
    field $root  :param :reader;
    field $start :param :reader;

    method walk ($mode, $f) {
        return Allium::Optree::Walker::TopDown   ->new( f => $f )->walk( $root  ) if $mode eq 'top_down';
        return Allium::Optree::Walker::BottomUp  ->new( f => $f )->walk( $root  ) if $mode eq 'bottom_up';
        return Allium::Optree::Walker::ExecOrder ->new( f => $f )->walk( $start ) if $mode eq 'exec';
        die "Unknown walk mode($mode)";
    }
}

