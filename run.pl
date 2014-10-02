#! /usr/bin/perl

$n = $begin = $ARGV[0] || 600;
$n_steps = $ARGV[1] || 10;
$step = $ARGV[2] || 50;
%result;

for my $i (1 .. $n_steps) {
    `make test test_p`;
    chomp($time = qx(./test $n));
    chomp($time_p = qx(./test_p $n));
    $result{$n} = [$time, $time_p];
    print "step = $i/$n_steps n = $n time = $time time_p = $time_p\n";
    $n += $step; 
}

open(my $fh, ">", "output_${begin}_${n_steps}_${step}.txt") 
    or die "cannot open > output_${begin}_${n_steps}_${step}.txt: $!";

for $key (sort {$a <=> $b} keys %result) {
    print $fh "$key @{$result{$key}}\n";
}

close $fh;
