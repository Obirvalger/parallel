#! /usr/bin/perl

use v5.14;
use warnings;

my @threads = (4,6,8); #array of numbers of threads for parallel program
my $n = my $begin = $ARGV[0] || 600;
my $n_steps = $ARGV[1] || 5;
my $step = $ARGV[2] || 50;
my %result;

for my $i (1 .. $n_steps) {
    `make test test_p`;
    my %times;
    chomp($times{0} = qx(./test $n));
    for my $j (@threads) {
	chomp($times{$j} = qx(./test_p $n $j));
    }
    $result{$n} = \%times;
    print "step = $i/$n_steps n = $n maxtime = $times{0} mintime = ";
    print ((sort values %times)[0], "\n");
    $n += $step;
}

open(my $fh, ">", "output_${begin}_${n_steps}_${step}.txt")
    or die "cannot open > output_${begin}_${n_steps}_${step}.txt: $!";

for my $k1 (sort {$a <=> $b} keys %result) {
    for my $k2 (sort {$a <=> $b} keys %{$result{$k1}}) {
	print $fh "$k2=$result{$k1}{$k2}  ";
    }
    print $fh "\n"
}

close $fh;
