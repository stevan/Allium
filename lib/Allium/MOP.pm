
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

class Allium::MOP {
    field @arena;

    field $root;
    field $main :reader;

    ADJUST {
        $root = $self->allocate(Allium::MOP::Stash::);
        $main = $root->set( $self->allocate_glob( 'main::' ) );
    }

    ## ---------------------------------------------------------------------------------------------

    our $OID_SEQ = 0;

    my sub next_OID { ++$OID_SEQ }
    my sub last_OID {   $OID_SEQ }

    ## ---------------------------------------------------------------------------------------------

    my sub decompose_identifier ($identifier) {
        my ($sigil, $name) = ($identifier =~ /^([\$\@\%\&\*]?)(.*)$/);
        my @parts = grep $_, split /([A-Za-z_][A-Za-z0-9_]+\:\:)/ => $name;
        return $sigil, @parts;
    }

    ## ---------------------------------------------------------------------------------------------

    method lookup ($identifier) {
        my ($sigil, @parts) = decompose_identifier($identifier);

        my $current = $main;
        while (@parts) {
            my $name = shift @parts;
            return unless $current->stash->has( $name );
            $current = $current->stash->get( $name );
        }

        return $current if $sigil eq '*';

        return $current->scalar if $sigil eq '$';
        return $current->array  if $sigil eq '@';
        return $current->hash   if $sigil eq '%';
        return $current->code   if $sigil eq '&';
    }

    method autovivify ($identifier) {
        my ($sigil, @parts) = decompose_identifier($identifier);

        #warn join ", " => $sigil, @parts;

        my $current = $main;
        while (@parts) {
            my $name = shift @parts;
            if ($current->stash->has( $name )) {
                $current = $current->stash->get( $name );
            }
            else {
                $current = $current->stash->set( $self->allocate_glob( $name ) );
            }
        }

        return $current if $sigil eq '*';

        return $current->scalar //= $self->allocate_scalar           if $sigil eq '$';
        return $current->array  //= $self->allocate_array            if $sigil eq '@';
        return $current->hash   //= $self->allocate_hash             if $sigil eq '%';
        return $current->code   //= $self->allocate_code( $current ) if $sigil eq '&';
    }

    ## ---------------------------------------------------------------------------------------------

    method walk ($f, $depth=0) {
        $self->walk_namespace($main, $f, $depth);
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
