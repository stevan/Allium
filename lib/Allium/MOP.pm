
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
    field %arena;

    field $root;
    field $main :reader;

    ADJUST {
        $root = Allium::MOP::Stash->new;
        $main = $root->set( $self->allocate_glob( 'main::' ) );
    }

    my sub decompose_identifier ($identifier) {
        my ($sigil, $name) = ($identifier =~ /^([\$\@\%\&\*]?)(.*)$/);
        my @parts = grep $_, split /([A-Za-z_][A-Za-z0-9_]+\:\:)/ => $name;
        return $sigil, @parts;
    }

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

    method dump_arena { \%arena }

    method add_to_arena ($o) { $arena{ $o->OID } = $o }

    method allocate_scalar { $self->add_to_arena(Allium::MOP::ScalarValue->new) }
    method allocate_array  { $self->add_to_arena(Allium::MOP::ArrayValue->new)  }
    method allocate_hash   { $self->add_to_arena(Allium::MOP::HashValue->new)   }

    method allocate_glob ($name) {
        $self->add_to_arena(Allium::MOP::GlobValue->new( name => $name ))
    }

    method allocate_code ($glob) {
        $self->add_to_arena(Allium::MOP::CodeValue->new( glob => $glob ))
    }
}
