
use v5.40;
use experimental qw[ class ];

use Allium::Operation::OP;
use Allium::Operation::SVOP;
use Allium::Operation::PADOP;
use Allium::Operation::PVOP;
use Allium::Operation::COP;
use Allium::Operation::METHOP;
use Allium::Operation::UNOP;
use Allium::Operation::UNOP_AUX;
use Allium::Operation::LOGOP;
use Allium::Operation::BINOP;
use Allium::Operation::LISTOP;
use Allium::Operation::PMOP;
use Allium::Operation::LOOP;

use Allium::Flags::Operation::PublicFlags;
use Allium::Flags::Operation::PrivateFlags;

package Allium::Operations {
    use v5.40;

    sub build($, $type, %args) {
        my $class = sprintf 'Allium::Operation::%s' => $type;
        return $class->new( %args );
    }
}
