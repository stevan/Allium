
use v5.40;
use experimental qw[ class ];

class Allium::Opcode::Flags {
    field $needs_stack_mark                         :param :reader = false;
    field $fold_constants                           :param :reader = false;
    field $always_produces_scalar                   :param :reader = false;
    field $needs_target_scalar                      :param :reader = false;
    field $needs_target_scalar_which_may_be_lexical :param :reader = false;
    field $always_produces_integer                  :param :reader = false;
    field $has_corresponding_int_op                 :param :reader = false;
    field $danger_make_temp_copy_in_list_assignment :param :reader = false;
    field $defaults_to_topic                        :param :reader = false;

    method get_flags_as_hash {
        return (
            ($needs_stack_mark                         ? (needs_stack_mark                          => 1) : ()),
            ($fold_constants                           ? (fold_constants                            => 1) : ()),
            ($always_produces_scalar                   ? (always_produces_scalar                    => 1) : ()),
            ($needs_target_scalar                      ? (needs_target_scalar                       => 1) : ()),
            ($needs_target_scalar_which_may_be_lexical ? (needs_target_scalar_which_may_be_lexical  => 1) : ()),
            ($always_produces_integer                  ? (always_produces_integer                   => 1) : ()),
            ($has_corresponding_int_op                 ? (has_corresponding_int_op                  => 1) : ()),
            ($danger_make_temp_copy_in_list_assignment ? (danger_make_temp_copy_in_list_assignment  => 1) : ()),
            ($defaults_to_topic                        ? (defaults_to_topic                         => 1) : ()),
        );
    }
}
