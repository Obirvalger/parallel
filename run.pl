#! /usr/bin/perl

$step = 50;
$n = $begin = 1000;
$n_steps = 40;
%result;
#~ $end = $begin * $n_steps;

for (my $i = 0; $i < $n_steps;  ++$i) {
    #~ print "i = $i\n";
    $time = qx(./test $n);
    $result{$n} = $time;
    print "step = ",$i+1,"/$n_steps n = $n time = $time";
    $n += $step; 
}

#~ print "Hi\n";

open(my $fh, ">", "output_${begin}_${n_steps}_${step}.txt") 
    or die "cannot open > output_${begin}_${n_steps}_${step}.txt: $!";

for $key (sort {$a <=> $b} keys %result) {
    print $fh "$key $result{$key}"
}

close $fh;
