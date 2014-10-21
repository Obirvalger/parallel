#! /usr/bin/perl

use v5.14;
use warnings;

for my $i (5..10) {
    #~ say "i = $i";
    my $n = $i * 1;
    system "./main in$n.txt out$n.txt $n";
    system "./main_p in$n.txt out_p$n.txt";
    system "perl mpi_fw_run.pl in$n.txt out_m$n.txt";
    open OUTG, "<out$n.txt";
    open OUTG_P, "<out_p$n.txt";
    open OUTG_M, "<out_m$n.txt";
    while (<OUTG>) {
	my $p = <OUTG_P>;
	my $m = <OUTG_M>;
	say "_ = $_";
	say "p = $p";
	say "m = $m";
	die "All wrong!" if $_ ne $p or $_ ne $m;
    }
}
