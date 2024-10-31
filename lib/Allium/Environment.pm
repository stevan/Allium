
use v5.40;
use experimental qw[ class ];

use Allium::Environment::Binding;
use Allium::Environment::Symbol;
use Allium::Environment::Value;

class Allium::Environment {
    field @bindings :reader;

    ## ---------------------------------------------------------------------------------------------

    method parse_symbol ($string) { Allium::Environment::Symbol->parse($string) }

    method wrap_optree ($optree) {
        Allium::Environment::Value::Optree->new( optree => $optree );
    }

    method wrap_literal ($literal) {
        # TODO:
        # later we can add more value types and this
        # can get more intelligent
        Allium::Environment::Value::Literal->new( literal => $literal );
    }

    ## ---------------------------------------------------------------------------------------------

    method bind ($symbol, $value) {
        my $binding = Allium::Environment::Binding->new(
            symbol => $symbol,
            value  => $value,
        );
        $self->add_binding( $binding );
        return $binding;
    }

    method add_binding ($binding) { $self->add_bindings($binding) }

    method add_bindings (@binds) {
        push @bindings => @binds;
        return $self;
    }

    ## ---------------------------------------------------------------------------------------------

    method relocate ($new_stash) {
        Allium::Environment->new->add_bindings(
            map {
                $_->copy( symbol => $_->symbol->relocate($new_stash) )
            } @bindings
        );
    }
}


