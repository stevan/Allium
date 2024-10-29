
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Symbol {
    use constant SCALAR => 'SCALAR';
    use constant ARRAY  => 'ARRAY';
    use constant HASH   => 'HASH';
    use constant CODE   => 'CODE';
    use constant GLOB   => 'GLOB';

    our (@SLOTS, %SIGIL_TO_SLOT, %SLOT_TO_SIGIL);
    BEGIN {
        %SIGIL_TO_SLOT = (
            '$' => SCALAR,
            '@' => ARRAY,
            '%' => HASH,
            '&' => CODE,
            '*' => GLOB,
        );
        %SLOT_TO_SIGIL = reverse %SIGIL_TO_SLOT;
        @SLOTS         = keys    %SLOT_TO_SIGIL;
    }

    field $symbol :param :reader;

    field $sigil :reader;
    field @path  :reader;

    ADJUST {
        ($sigil, @path) = grep $_,
                          split /(\$|\@|\%|\&|\*|[A-Za-z][A-Za-z0-9]+\:\:)/
                            => $symbol;
    }

    method type { $SIGIL_TO_SLOT{ $sigil } // die "WTF $symbol" }

    method name      { $path[-1] }
    method namespace { join '', @path[ 0 .. ($#path - 1) ] }

    method decompose { $sigil, @path }

    method equal_to ($s) { $s->symbol eq $symbol }

    method copy_as ($type) {
        Allium::MOP::Symbol->new( symbol => join '', $SLOT_TO_SIGIL{ $type }, @path )
    }
}
