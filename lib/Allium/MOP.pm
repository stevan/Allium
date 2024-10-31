
use v5.40;
use experimental qw[ class ];

use Allium::MOP::Stash;
use Allium::MOP::Pad;

use Allium::MOP::ScalarValue;
use Allium::MOP::ArrayValue;
use Allium::MOP::HashValue;
use Allium::MOP::CodeValue;
use Allium::MOP::GlobValue;

use Allium::Environment;
use Allium::Environment::Symbol;

class Allium::MOP {
    field @arena;

    field $root;
    field $main :reader;
    field $root_env  :reader;

    field %symbol_table;

    ADJUST {
        $root_env = Allium::Environment->new;
        $root     = $self->allocate(Allium::MOP::Stash::);
        $main     = $root->set( $self->allocate_glob( 'main::' ) );
    }

    ## ---------------------------------------------------------------------------------------------

    method load_environment ($e) {
        foreach my $binding ($e->bindings) {
            $self->bind( $binding );
        }
        $self;
    }

    method bind ($binding) {
        $root_env->add_binding( $binding );
        my $val = $self->autovivify( $binding->symbol );
        $val->add_binding( $binding );
        return $val;
    }

    ## ---------------------------------------------------------------------------------------------

    method lookup ($symbol) {
        $symbol = Allium::Environment::Symbol->parse($symbol) unless blessed $symbol;

        my ($sigil, @path) = $symbol->decompose;

        my $current = $main;
        while (@path) {
            my $name = shift @path;
            return unless $current->stash->has( $name );
            $current = $current->stash->get( $name );
        }

        return $current         if $symbol isa Allium::Environment::Symbol::Glob;
        return $current->scalar if $symbol isa Allium::Environment::Symbol::Scalar;
        return $current->array  if $symbol isa Allium::Environment::Symbol::Array;
        return $current->hash   if $symbol isa Allium::Environment::Symbol::Hash;
        return $current->code   if $symbol isa Allium::Environment::Symbol::Code;
    }

    method autovivify ($symbol) {
        $symbol = Allium::Environment::Symbol->parse($symbol) unless blessed $symbol;

        my ($sigil, @path) = $symbol->decompose;

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

        return $current                                              if $symbol isa Allium::Environment::Symbol::Glob;
        return $current->scalar //= $self->allocate_scalar           if $symbol isa Allium::Environment::Symbol::Scalar;
        return $current->array  //= $self->allocate_array            if $symbol isa Allium::Environment::Symbol::Array;
        return $current->hash   //= $self->allocate_hash             if $symbol isa Allium::Environment::Symbol::Hash;
        return $current->code   //= $self->allocate_code( $current ) if $symbol isa Allium::Environment::Symbol::Code;
    }

    ## ---------------------------------------------------------------------------------------------

    our $OID_SEQ = 0;

    my sub next_OID { ++$OID_SEQ }
    my sub last_OID {   $OID_SEQ }

    ## ---------------------------------------------------------------------------------------------

    method walk ($f, $depth=0) {
        $self->walk_namespace($main, $f, $depth);
    }

    method walk_globs ($f) {
        $self->walk(sub ($glob, $depth) {
            foreach my $g (sort { $a->oid <=> $b->oid } $glob->stash->get_all_globs) {
                $f->($g);
            }
        })
    }

    method walk_namespace ($glob, $f, $depth=0) {
        $f->($glob, $depth);
        foreach my $g (sort { $a->oid <=> $b->oid } $glob->stash->get_all_namespaces) {
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
        $arena[ $next_OID ] = $class->new( oid => $next_OID, %args );
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
