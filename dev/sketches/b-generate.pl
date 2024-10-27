#!perl

use v5.40;

use B::Generate;


use A;
use Allium::Optree::Dumper;
use Allium::Optree::Loader;

sub foo {
    say 10, 20, 30, 40, 50;
}

CHECK {
    my $foo = B::svref_2object(\&foo);

    sub make_sub ($first, $last) {
        my $lineseq  = B::LISTOP->new( "lineseq", B::OPf_PARENS, $first, $last );
        my $leavesub = B::UNOP->new( "leavesub", 0, $lineseq );
        $leavesub->private(B::OPpREFCOUNTED | B::OPpARG1_MASK);
        return $leavesub;
    }

    sub make_list (@constants) {
        my @ops = ( B::OP->new( "pushmark", 0 ) );
        foreach my $const (@constants) {
            push @ops => B::SVOP->new( "const", 0, $const );
        }
        return \@ops;
    }

    sub make_statement {
        return B::COP ->new( 0, "", 0 );
    }

    sub make_say ($first, $last) {
        return B::LISTOP->new( "say", B::OPf_WANT_SCALAR, $first, $last );
    }

    sub connect_say ($op, $list) {
        $list->[-1]->next($op);
    }

    sub connect_statement ($cop, $op) {
        $cop->sibling($op);
        $cop->next($op->first);
    }

    sub connect_sub ($leavesub) {
        # connect the lineseq to the leavesub
        my $lineseq = $leavesub->first;
        $lineseq->next($leavesub);
        # connec the end to the leavesub
        my $end = $lineseq->last;
        $end->next($leavesub);
    }

    sub connect_list ($list) {
        foreach my ($i, $op) (indexed @$list) {
            last if $i == $#{ $list };
            my $next = $list->[$i + 1];
            $op->next($next);
            $op->sibling($next);
        }
    }

    my $stmnt    = make_statement;
    my $list     = make_list(1 .. 5);
    my $say      = make_say( $list->[0], $list->[-1] );
    my $leavesub = make_sub($stmnt, $say);

    connect_list($list);
    connect_say($say, $list);
    connect_statement($stmnt, $say);
    connect_sub($leavesub);

    #warn join "\n" => map {
    #    join ", " => $_->name, ${$_}, $_->next->name, ${$_->next}, $_->sibling, ${$_->sibling}
    #} @$ops;

    my $foo2 = $foo->NEW_with_start (
        $leavesub,
        $stmnt
    )->object_2svref;

    *main::foo2 = $foo2;
}

sub pprint ($op) { say($op->addr,('  ' x $op->depth),join ':' => $op->type, $op->name) }
my $orig = A->new->disassemble(\&foo2);
$orig->walk(top_down => \&pprint);

foo();
foo2();

#warn join "\n" => map {
#    join ", " => $_->name, ${$_}, $_->next->name, ${$_->next}, $_->sibling, ${$_->sibling}
#} @$OPS;


__END__


    my $foo = B::svref_2object(\&foo);


    my         $const_20 = B::SVOP    ->new( "const", 0, 20 );
    my         $const_10 = B::SVOP    ->new( "const", 0, 10 );
    my         $pushmark = B::OP      ->new( "pushmark", 0 );
    my     $say          = B::LISTOP  ->new( "say", 0, $pushmark, $const_20 );
    my     $cop          = B::COP     ->new( 0, "hiya", 0 );
    my     $enter        = B::OP      ->new( "enter",0 );
    my $leave            = B::LISTOP  ->new( "leave", 0, $enter, $say );

    $pushmark  ->sibling($const_10);
    $pushmark  ->next($const_10);

    $const_10  ->sibling($const_20);
    $const_10  ->next($const_20);

    $const_20   ->next($say);


    $enter      ->sibling($cop);
    $enter      ->next($cop);

    $cop        ->sibling($say);
    $cop        ->next($pushmark);

    $say        ->next($leave);

    my $foo2 = $foo->NEW_with_start (
        $leave,
        $enter
    )->object_2svref;

## ------------------------------------------------------------



CHECK {
    my $const_10 = B::SVOP->new("const", 0, 10);
    my $pushmark = B::OP->new("pushmark", 0);
    $pushmark->sibling($const_10);
    $pushmark->next($const_10);

    my $print = B::LISTOP->new("print", 0, $pushmark, $const_10);
    $const_10->next($print);

    my $enter = B::OP->new("enter",0);
    my $cop = B::COP->new(0, "hiya", 0);
    my $leave = B::LISTOP->new("leave", 0, $enter, $print);

    $enter->sibling($cop);
    $enter->next($cop);
    $cop->sibling($print);
    $cop->next($pushmark);
    $print->next($leave);

    B::main_root($leave);
    B::main_start($enter);
}

