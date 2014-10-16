#! /usr/bin/perl

use v5.14;
use warnings;

for my $i (5..10) {
    #~ say "i = $i";
    my $n = $i * 200;
    system "../main in$n.txt out$n.txt $n";
    system "../main_p in$n.txt out_p$n.txt";
    open OUTG, "<out$n.txt";
    open OUTG_P, "<out_p$n.txt";
    while (<OUTG>) {
	my $p = <OUTG_P>;
	#~ say "_ = $_";
	#~ say "p = $p";
	die "All wrong!" if $_ ne $p;
    }
}
