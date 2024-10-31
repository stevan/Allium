
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Stash;
use Allium::MOP::Pad;

use Allium::MOP::Value::Type;

use Allium::MOP::ScalarValue;
use Allium::MOP::ArrayValue;
use Allium::MOP::HashValue;
use Allium::MOP::CodeValue;
use Allium::MOP::GlobValue;

use Allium::MOP::Symbol;

class Allium::MOP {
    field @arena;

    field $root;
    field $main :reader;

    field %symbol_table;

    ADJUST {
        $root = $self->allocate(Allium::MOP::Stash::);
        $main = $root->set( $self->allocate_glob( 'main::' ) );
    }

    ## ---------------------------------------------------------------------------------------------

    our $OID_SEQ = 0;

    my sub next_OID { ++$OID_SEQ }
    my sub last_OID {   $OID_SEQ }

    ## ---------------------------------------------------------------------------------------------

    method new_symbol ($name) { Allium::MOP::Symbol->new( symbol => $name ) }

    ## ---------------------------------------------------------------------------------------------

    method lookup ($symbol) {
        $symbol = $self->new_symbol($symbol) unless blessed $symbol;

        my @path = $symbol->path;

        my $current = $main;
        while (@path) {
            my $name = shift @path;
            return unless $current->stash->has( $name );
            $current = $current->stash->get( $name );
        }

        return $current if $symbol->type eq $symbol->GLOB;

        return $current->scalar if $symbol->type eq $symbol->SCALAR;
        return $current->array  if $symbol->type eq $symbol->ARRAY;
        return $current->hash   if $symbol->type eq $symbol->HASH;
        return $current->code   if $symbol->type eq $symbol->CODE;
    }

    method autovivify ($symbol) {
        $symbol = $self->new_symbol($symbol) unless blessed $symbol;

        my @path = $symbol->path;

        my $current = $main;
        while (@path) {
            my $name = shift @path;
            if ($current->stash->has( $name )) {
                $current = $current->stash->get( $name );
            }
            else {
                $current = $current->stash->set( $self->allocate_glob( $name ) );
            }
        }

        return $current if $symbol->type eq $symbol->GLOB;

        return $current->scalar //= $self->allocate_scalar           if $symbol->type eq $symbol->SCALAR;
        return $current->array  //= $self->allocate_array            if $symbol->type eq $symbol->ARRAY;
        return $current->hash   //= $self->allocate_hash             if $symbol->type eq $symbol->HASH;
        return $current->code   //= $self->allocate_code( $current ) if $symbol->type eq $symbol->CODE;
    }

    ## ---------------------------------------------------------------------------------------------

    method walk ($f, $depth=0) {
        $self->walk_namespace($main, $f, $depth);
    }

    method walk_globs ($f) {
        $self->walk(sub ($glob, $depth) {
            foreach my $g (sort { $a->OID <=> $b->OID } $glob->stash->get_all_globs) {
                $f->($g);
            }
        })
    }

    method walk_namespace ($glob, $f, $depth=0) {
        $f->($glob, $depth);
        foreach my $g (sort { $a->OID <=> $b->OID } $glob->stash->get_all_namespaces) {
            $self->walk_namespace($g, $f, $depth + 1);
        }
    }

    method walk_arena ($f) {
        my $oid = 0;
        while ($oid < last_OID) {
            $oid++;
            $f->( $arena[ $oid ] );
        }
    }

    ## ---------------------------------------------------------------------------------------------

    method dump_arena { \@arena }

    method allocate ($class, %args) {
        my $next_OID = next_OID;
        $arena[ $next_OID ] = $class->new( __oid => $next_OID, %args );
    }

    method allocate_scalar {
        $self->allocate(Allium::MOP::ScalarValue:: => ());
    }

    method allocate_array  {
        $self->allocate(Allium::MOP::ArrayValue:: => ());
    }

    method allocate_hash   {
        $self->allocate(Allium::MOP::HashValue:: => ());
    }

    method allocate_glob ($name) {
        my $glob = $self->allocate(Allium::MOP::GlobValue:: => (name => $name));

        $glob->hash = $self->allocate(Allium::MOP::Stash::)
            if $glob->is_namespace;

        return $glob;
    }

    method allocate_code ($glob) {
        $self->allocate(Allium::MOP::CodeValue:: => (glob => $glob));
    }

    ## ---------------------------------------------------------------------------------------------
}
