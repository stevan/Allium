

use v5.40;
use experimental qw[ class ];

class Allium::Flags::Operation::PublicFlags {
    field $bits :param :reader;

    field $wants_void   :param :reader;
    field $wants_scalar :param :reader;
    field $wants_list   :param :reader;

    field $has_descendents    :param :reader;
    field $was_parenthesized  :param :reader;
    field $return_container   :param :reader;
    field $is_lvalue          :param :reader;
    field $is_mutator_varient :param :reader;
    field $is_special         :param :reader;

    method to_string (%opts) {
        my $seperator = $opts{seperator} // ', ';
        my $verbosity = $opts{verbosity} // 0;

        return join $seperator => (
            ($wants_void         ? '<~V' : ()),
            ($wants_scalar       ? '<~S' : ()),
            ($wants_list         ? '<~L' : ()),
            ($has_descendents    ? '@+K' : ()),
            ($was_parenthesized  ? '()?' : ()),
            ($is_lvalue          ? '$<-' : ()),
            ($is_mutator_varient ? 'op=' : ()),
            ($is_special         ? 'SPC' : ()),
            ($return_container   ? '->$' : ()),
        ) if $verbosity < 0;

        return join $seperator => (
            ($wants_void         ? 'want(v)' : ()),
            ($wants_scalar       ? 'want(s)' : ()),
            ($wants_list         ? 'want(l)' : ()),
            ($has_descendents    ? '@(kids)' : ()),
            ($was_parenthesized  ? '(paren)' : ()),
            ($is_lvalue          ? 'lval(v)' : ()),
            ($is_mutator_varient ? 'mutates' : ()),
            ($return_container   ? 'r(cont)' : ()),
            ($is_special         ? 'special' : ()),
        ) if $verbosity == 0;

        return join $seperator => (
            ($wants_void         ? 'wants_void'         : ()),
            ($wants_scalar       ? 'wants_scalar'       : ()),
            ($wants_list         ? 'wants_list'         : ()),
            ($has_descendents    ? 'has_descendents'    : ()),
            ($was_parenthesized  ? 'was_parenthesized'  : ()),
            ($is_lvalue          ? 'is_lvalue'          : ()),
            ($is_mutator_varient ? 'is_mutator_varient' : ()),
            ($return_container   ? 'return_container'   : ()),
            ($is_special         ? 'is_special'         : ()),
        ) if $verbosity > 0;
    }
}
