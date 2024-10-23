
use v5.40;
use experimental qw[ class ];

class Allium::Opcode::ArgType {
    use constant ();
    our @TYPES;
    BEGIN {
     constant->import( $_, $_ )
        foreach @TYPES = qw[
            SCALAR
            HASH
            NUMERIC
            LIST
            CODE
            ARRAY
            REF
            BINARY
            SOCKET
            FILETEST
            DIR
            FILE
            FILETEST_ACCESS];
    }
}
