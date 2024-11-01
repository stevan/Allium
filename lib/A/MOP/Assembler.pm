
use v5.40;
use experimental qw[ class ];

use B ();

class A::MOP::Assembler {
    field $op_assembler :param :reader;

    method assemble ($mop) {
        my $env = $mop->root_env;
        $self->load_environment($env);
        return true;
    }

    method load_environment ($env) {
        #say ".... loading environment";
        no strict 'refs';

        foreach my $binding ($env->bindings) {
            my $value  = $binding->value;
            my $symbol = $binding->symbol;

            #say ".... binding for ($symbol) to ($value)";

            if ($value isa Allium::Environment::Value::Literal) {
                #say ">>>> binding a literal ...";
                my $lit = $value->literal;
                if (ref $lit) {
                    #say ">>>> binding a ref literal ...";
                    if (reftype $lit eq 'ARRAY') {
                        @{$symbol->glob_name} = @$lit;
                    }
                    elsif (reftype $lit eq 'HASH') {
                        %{$symbol->glob_name} = %$lit;
                    }
                    else {
                        die "Only ARRAY and HASH refs are supported when loading environment";
                    }
                }
                else {
                    #say ">>>> binding a non-ref literal to ",$symbol->glob_name;
                    ${$symbol->glob_name} = $lit;
                }
            }
            elsif ($value isa Allium::Environment::Value::Optree) {
                #say ">>>> binding a code-ref to ",$symbol->glob_name;
                my $code = $self->assemble_optree( $value->optree );
                #say ">>>> got code ref $code";
                *{$symbol->glob_name} = $code;
            }
            else {
                die "This should never happen!"
            }

            #say "<<<< bound ($symbol) to ($value)";
        }
    }

    method assemble_optree ($optree) {
        return $op_assembler->assemble($optree)
    }
}
