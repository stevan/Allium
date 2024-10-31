use v5.40;

package Foo {

    our $BAR = 'huh?';
    BEGIN { $BAR = 'BAR!!' }

    sub foo {
        say 10, 20, 30, 40;
    }

    sub bar {
        $BAR;
    }
}

