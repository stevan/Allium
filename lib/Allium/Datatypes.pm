
use v5.40;
use experimental qw[ class ];

package Allium::Datatypes {

    class Allium::Datatype::Value {
        use constant ();
        our @TYPES;
        BEGIN {
         constant->import( $_, $_ )
            foreach @TYPES = qw[
                IV
                NV
                PV
            ];
        }
    }

    class Allium::Datatype::Container {
        use constant ();
        our @TYPES;
        BEGIN {
         constant->import( $_, $_ )
            foreach @TYPES = qw[
                SV
                AV
                HV
                CV
                GV
                RV
            ];
        }
    }

    class Allium::Datatype::Arg {
        use constant ();
        our @TYPES;
        BEGIN {
         constant->import( $_, $_ )
            foreach @TYPES = qw[
                SCALAR
                NUMERIC
                ARRAY
                HASH
                CODE
                REF
                LIST
                BINARY
                SOCKET
                FILETEST
                DIR
                FILE
                FILETEST_ACCESS
            ];
        }
    }

}
