
use v5.40;
use experimental qw[ class ];

class Allium::MOP::Pad::Var {
    field $index :param :reader;
    field $value :param :reader;
}

class Allium::MOP::Pad {
    field @vars :reader;

    method new_var ($value) {
        my $new_var = Allium::MOP::Pad::Var->new(
            index => (scalar @vars),
            value => $value,
        );
        push @vars => $new_var;
        return $new_var;
    }
}
