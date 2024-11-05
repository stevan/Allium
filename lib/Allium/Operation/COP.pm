
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

    method label      :lvalue { $label      } # string
    method stash      :lvalue { $stash      } # STASH->NAME
    method file       :lvalue { $file       } # string
    method cop_seq    :lvalue { $cop_seq    } # number
    method line       :lvalue { $line       } # number
    method warnings   :lvalue { $warnings   } # B::PV->PV
    method io         :lvalue { $io         } # B::SPECIAL #IGNORED
    method hints      :lvalue { $hints      } # number
    method hints_hash :lvalue { $hints_hash } # B::RHE->HASH
}
