

use v5.40;
use experimental qw[ class ];

class Allium::Flags::Operation::PublicFlags {
    field $bits :param :reader;

    field $wants_void   :param :reader = false;
    field $wants_scalar :param :reader = false;
    field $wants_list   :param :reader = false;

    field $has_descendents    :param :reader = false;
    field $was_parenthesized  :param :reader = false;
    field $return_container   :param :reader = false;
    field $is_lvalue          :param :reader = false;
    field $is_mutator_varient :param :reader = false;
    field $is_special         :param :reader = false;

    method dump_flags {
        return +{
            bits => $bits,
            ($wants_void         ? (wants_void         => true) : ()),
            ($wants_scalar       ? (wants_scalar       => true) : ()),
            ($wants_list         ? (wants_list         => true) : ()),
            ($has_descendents    ? (has_descendents    => true) : ()),
            ($was_parenthesized  ? (was_parenthesized  => true) : ()),
            ($return_container   ? (return_container   => true) : ()),
            ($is_lvalue          ? (is_lvalue          => true) : ()),
            ($is_mutator_varient ? (is_mutator_varient => true) : ()),
            ($is_special         ? (is_special         => true) : ()),
        }
    }

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
