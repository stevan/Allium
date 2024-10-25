

use v5.40;
use experimental qw[ class ];

# NOTE:
# just add flags here when needed

class Allium::Flags::Operation::PrivateFlags {
    field $bits :param :reader;

    field $introduces_lexical :param :reader = false;
    field $has_pad_target     :param :reader = false;

    method dump_flags {
        return +{
            bits => $bits,
            ($introduces_lexical ? (introduces_lexical => true) : ()),
            ($has_pad_target     ? (has_pad_target     => true) : ()),
        }
    }

    method to_string (%opts) {
        my $seperator = $opts{seperator} // ', ';
        my $verbosity = $opts{verbosity} // 0;

        return join $seperator => (
            ($introduces_lexical ? '^(l)'  : ()),
            ($has_pad_target     ? '>(p)' : ()),
        ) if $verbosity < 0;

        return join $seperator => (
            ($introduces_lexical ? 'intro(lex)'  : ()),
            ($has_pad_target     ? 'target(pad)' : ()),
        ) if $verbosity == 0;

        return join $seperator => (
            ($introduces_lexical ? 'introduces_lexical' : ()),
            ($has_pad_target     ? 'has_pad_target'     : ()),
        ) if $verbosity > 0;
    }
}
