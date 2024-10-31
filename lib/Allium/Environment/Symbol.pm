
use v5.40;
use experimental qw[ class ];

class Allium::Environment::Symbol {
    field $name  :param;
    field $stash :param;

    sub parse ($, $string) {
        my ($sigil, @path) = grep $_, split /(\$|\@|\%|\&|\*|[A-Za-z][A-Za-z0-9]+\:\:)/ => $string;
        die "Could not parse symbol ($string)"
            unless $sigil && @path;

        my $name = pop @path;
        my %args = ( name => $name, stash => \@path );
        return Allium::Environment::Symbol::Scalar ->new( %args ) if $sigil eq '$';
        return Allium::Environment::Symbol::Array  ->new( %args ) if $sigil eq '@';
        return Allium::Environment::Symbol::Hash   ->new( %args ) if $sigil eq '%';
        return Allium::Environment::Symbol::Code   ->new( %args ) if $sigil eq '&';
        return Allium::Environment::Symbol::Glob   ->new( %args ) if $sigil eq '*';

        die "Unknown Sigil ($sigil)";
    }

    method sigil;

    method name  { $name  }
    method stash { $stash }

    method stash_name { join '' => @$stash }
    method local_name { join '' => $self->sigil, $name }
    method full_name  { join '' => $self->decompose    }

    method decompose { $self->sigil, @$stash, $name }

    method is_same_as ($symbol) {
        $self->full_name eq $symbol->full_name
    }
}

class Allium::Environment::Symbol::Scalar :isa(Allium::Environment::Symbol) {
    method sigil { '$' }
}

class Allium::Environment::Symbol::Array :isa(Allium::Environment::Symbol) {
    method sigil { '@' }
}

class Allium::Environment::Symbol::Hash :isa(Allium::Environment::Symbol) {
    method sigil { '%' }
}

class Allium::Environment::Symbol::Code :isa(Allium::Environment::Symbol) {
    method sigil { '&' }
}

class Allium::Environment::Symbol::Glob :isa(Allium::Environment::Symbol) {
    method sigil { '*' }
    method is_stash { !! ($self->name =~ /\:\:$/) }
}



