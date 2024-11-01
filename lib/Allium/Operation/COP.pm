
use v5.40;
use experimental qw[ class ];

class Allium::Operation::COP :isa(Allium::Operation::OP) {
    field $label;
    field $stash;
    field $file;
    field $cop_seq;
    field $line;
    field $warnings;
    field $io;
    field $hints;
    field $hints_hash;

    method label      :lvalue { $label      }
    method stash      :lvalue { $stash      }
    method file       :lvalue { $file       }
    method cop_seq    :lvalue { $cop_seq    }
    method line       :lvalue { $line       }
    method warnings   :lvalue { $warnings   }
    method io         :lvalue { $io         }
    method hints      :lvalue { $hints      }
    method hints_hash :lvalue { $hints_hash }
}
