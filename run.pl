#! /usr/bin/perl

use v5.14;
use warnings;

my @threads = (8); #array of numbers of threads for parallel program
my $n = my $begin = 600;
my $n_steps = 5;
my $step = 50;
my %result;
my $outfile = "output.txt";
my $directly_print = 0;

if ($ARGV[0]) {
    open(RC, "<$ARGV[0]") or die "cannot open > $ARGV[0] $!";
} else {
    open(RC, "<runrc") or warn "cannot open runrc values of variables reads from script\n";
}

while (<RC>) {
    #~ print;
    chomp;
    if (s/^\s*begin\s*=\s*(\d+).*/$1/) {$n = $begin = $_}
    elsif (s/^\s*n_steps\s*=\s*(\d+).*/$1/) {$n_steps = $_}
    elsif (s/^\s*step\s*=\s*(\d+).*/$1/) {$step = $_}
    elsif (s/^\s*outfile\s*=\s*(["']?)([\.\d\w\s]*[\.\d\w])\1.*/$2/x) {$outfile = $_}
    elsif (s/^\s*threads\s*=\s*([\d\s,]+).*/$1/) {@threads = split /[\s,]*/}
    elsif (s/^\s*directly_print\s*=\s*(\d).*/$1/) {$directly_print = $_}
    #~ print "$&; $outfile\n";
}

#~ print "@threads\n";
#~ print "=$outfile= \n";
open(my $fh, ">", $outfile)
    or die "cannot open > $outfile $!";

#~ `make test test_p`;

for my $i (1 .. $n_steps) {
    my %times;
    chomp($times{0} = qx(./test $n));
    for my $j (@threads) {
	chomp($times{$j} = qx(./test_p $n $j));
    }
    $result{$n} = \%times;
    printf "step = $i/$n_steps  n = $n  maxtime = %f  mintime = %f\n", $times{0}, $times{$threads[0]};
    if ($directly_print) {
	printf $fh "%d ", $n;
	for my $key (sort {$a <=> $b} keys %times) {
	    printf $fh ("%f ", $times{$key});
	    #~ printf $fh ("%d=%f ", $k2, $times{$key});
	}
	print $fh "\n"
    }
    
    $n += $step;
}

unless ($directly_print) {
    for my $k1 (sort {$a <=> $b} keys %result) {
	printf $fh "%d ", $k1;
	for my $k2 (sort {$a <=> $b} keys %{$result{$k1}}) {
	    #~ printf $fh ("%f ", $result{$k1}{$k2});
	    printf $fh ("%d=%f ", $k2, $result{$k1}{$k2});
	}
	print $fh "\n"
    }
}

close $fh;
