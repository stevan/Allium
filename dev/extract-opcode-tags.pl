#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;

use Opcode qw[ opset_to_ops opset full_opset opdesc ];

my @base_tags = qw[
    :base_core
    :base_mem
    :base_loop
    :base_math
    :base_io
    :base_orig
    :load
];

my @filesys_tags = qw[
    :filesys_read
    :filesys_open
    :filesys_write
];

my @os_tags = qw[
    :sys_db
];

my @processes = qw[
    :subprocess
    :ownprocess
];

my @to_check = qw[
    :still_to_be_decided
    :dangerous
];

my @deprecate = qw[
    :base_thread
    :others
];


sub write_csv_for( $name, @tags ) {
    foreach my $tag (@tags) {
        my @opcodes = opset_to_ops(opset($tag));
        foreach my $opcode (@opcodes) {
            say join ',' => map { '"'.$_.'"' } ($opcode, opdesc($opcode), $name, $tag);
        }
    }
}

write_csv_for('Core'       => @base_tags);
write_csv_for('IO'         => @filesys_tags);
write_csv_for('Processes'  => @processes);
write_csv_for('OS'         => @os_tags);
write_csv_for('Deprecated' => @deprecate);

write_csv_for('TODO'       => @to_check);

done_testing;


