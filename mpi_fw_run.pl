#! /usr/bin/perl

use v5.14;
use warnings;
use autodie;
use File::Temp "tempfile";

die "Need two arguments: input output!" if (@ARGV < 2);

my $fw_mpi = "fw_mpi.c";
open(my $SC, "<$fw_mpi");
open(my $IG, "<$ARGV[0]");
open(my $OG, ">$ARGV[1]");

my ($fh, $fname) = tempfile(SUFFIX =>  ".ct12", DIR => '.', UNLINK => 1);

chomp (my $n = <$IG>);
chomp(my @graph = <$IG>);
for (@graph) {
    $_ = join(",", split(" ", $_));
    $_ = '{' . $_ . '}';
}

my $graph_str = '{' . join(',', @graph) . '};';

while(<$SC>) {
    s/#define n .*/#define n $n/;
    s/int dist\[n\]\[n\].*/int dist[n][n] = $graph_str/;
    #~ print;
    print $fh $_;
}

rename $fname, "$fw_mpi";
system("mpicc -o fw_mpi $fw_mpi");
my $strret = qx(mpirun -n 4 ./fw_mpi);
my ($strtime, $strout) = split("\n", $strret, 2);
printf "Time is equal %s\n", $strtime;
printf $OG "$strout\n";
