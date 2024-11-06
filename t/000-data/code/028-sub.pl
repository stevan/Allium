#!perl

use v5.40;

sub sub_028 {
    my $x = "10";
    my $y = int($x);
    my $z = ref($x);

    my $p = scalar($x);
    my $q = scalar($y);
    my $r = defined($y);
    my $s = is_weak($x);
    my $t = is_tainted($q);
    my $u = refaddr($r);
    my $v = reftype($r);
    my $w = ceil($r);

    my $c = floor($r);
    my $d = hex($y);
    my $e = oct($d);
    my $f = ord($s);
    my $g = chr($z);
    my $h = fc($v);
    my $i = lc($h);
    my $j = uc($g);
    my $k = ucfirst($d);
    my $l = lcfirst($d);
    my $m = length($k);
    my $n = chomp($m);
    my $o = chop($m);

    my $aa = abs($y);
    my $bb = cos($aa);
    my $cc = exp($aa);
    my $dd = log($aa);
    my $ee = sin($aa);
    my $ff = sqrt($aa);
    my $gg = quotemeta($aa);
    my $hh = blessed($aa);
}
