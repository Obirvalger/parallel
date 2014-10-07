#! /usr/bin/perl

use v5.14;
use warnings;

$, = " ";

my @threads = (8); #array of numbers of threads for parallel program
my $n = my $begin = 600;
my $n_steps = 5;
my $step = 50;
my %result;
my ($outfile, $pdf_table_file) = qw /output.txt table.pdf/;
my ($directly_print, $write_pdf_table) = (0, 0);

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
    elsif (s/^\s*pdf_table_file\s*=\s*(["']?)([\.\d\w\s]*[\.\d\w])\1.*/$2/x) {$pdf_table_file = $_}
    elsif (s/^\s*threads\s*=\s*[\[\(]?([\d\s,]+)[\]\)]?.*/$1/) {@threads = split /[\s,]*/}
    elsif (s/^\s*directly_print\s*=\s*(\d).*/$1/) {$directly_print = $_}
    elsif (s/^\s*write_pdf_table\s*=\s*(\d).*/$1/) {$write_pdf_table = $_}
    #~ print "$&; $outfile\n";
}

#~ print "@threads\n";
#~ print "=$outfile= \n";
open(my $fh, ">", $outfile)
    or die "cannot open > $outfile $!";

`make test test_p`;

if ($directly_print) {
    printf $fh "N 0 ";
    for (@threads) {
	printf $fh "$_ ";
    }
    print $fh "\n";
}

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
    printf $fh "N 0 ";
    for (@threads) {
	printf $fh "$_ ";
    }
    print $fh "\n";
    for my $k1 (sort {$a <=> $b} keys %result) {
	printf $fh "%d ", $k1;
	for my $k2 (sort {$a <=> $b} keys %{$result{$k1}}) {
	    printf $fh ("%f ", $result{$k1}{$k2});
	    #~ printf $fh ("%d=%f ", $k2, $result{$k1}{$k2});
	}
	print $fh "\n";
    }
}

close $fh;

make_pdf_table(\%result, $pdf_table_file) if $write_pdf_table;
make_pdf_plot(\%result, "myplot.pdf");

sub make_pdf_table {
    use File::Temp qw/ tempfile tempdir /;
    use File::Copy;
    
    my ($fh, $filename) = tempfile(SUFFIX => '.tex', DIR => ".", UNLINK => 1);
    #~ print "fname = $filename\n";
    my ($href, $pdf_table_file) = @_;
    
    my $hat = <<'END_HAT';
\documentclass[a4paper, 14pt]{extreport}
\usepackage[utf8]{inputenc}
\usepackage[russianb]{babel}
\usepackage{longtable, moreverb}
\usepackage{ amssymb, latexsym, amsmath}
\usepackage{vmargin}
\setpapersize{A4}
\setmarginsrb{2cm}{1.5cm}{2cm}{1.5cm}{0pt}{0mm}{0pt}{13mm}

\sloppy

\begin{document}

\begin{center}
END_HAT
    my $beg = "\\begin{longtable}[H]{|c|";
    my $hline = "\\hline \\textnumero";
    for my $k2 (sort {$a <=> $b} keys %{$href -> {(keys %$href)[0]}}) {
	    $beg .= 'l|';
	    $hline .= " & $k2 threads";
	}
    $beg .= "}\n";
    $hline .= "\\\\ \\hline \n";
    #~ print $hline;
    my $end = <<'END_END';
\end{longtable}
\end{center}
\end{document}
END_END
    
    print $fh $hat, $beg, $hline;
    for my $k1 (sort {$a <=> $b} keys %$href) {
	printf $fh '$%d$ ', $k1;
	for my $k2 (sort {$a <=> $b} keys %{$href -> {$k1}}) {
	    printf $fh ('& $%f$ ', $href -> {$k1}{$k2});
	    #~ printf $fh ("%d=%f ", $k2, $result{$k1}{$k2});
	}
	print $fh "\\\\ \\hline \n"
    }
    print $fh $end;
    
    `pdflatex $filename`;
    
    $filename =~ s/(.*).tex/$1/;
    unlink ($filename . ".aux");
    unlink ($filename . ".log");
    move(($filename . ".pdf"), $pdf_table_file);
    #~ copy($filename, "tmp.txt") or die "Copy failed: $!";
}

sub make_pdf_plot {
    use File::Temp qw/ tempfile tempdir /;
    use File::Copy;
    use Data::Dumper qw(Dumper);
    use List::MoreUtils qw(firstidx);
    
    my ($fh, $filename) = tempfile(SUFFIX => '.r', DIR => ".", UNLINK => 1);
    #~ print "fname = $filename\n";
    my ($href, $pdf_plot_file) = @_;
    my $tmpstr;
    my @threads = sort {$a <=> $b} keys %{$href -> {(keys %$href)[0]}};
    #~ print "threads " . join(', ', @threads) . "\n";
    
    #~ print $fh 'mtext(c("Low","High"),side=1,line=2,at=c(5,7))' . "\n";
    print $fh 'pdf(file="myplot.pdf")' . "\n";
    
    $tmpstr = "x <- c(";
    $tmpstr .= join(',', (sort {$a <=> $b} keys %$href));
    $tmpstr .= ")\n";
    print $fh $tmpstr;
    
    for my $i (@threads) {
	$tmpstr = "y$i <- c(";
	for my $key (sort {$a <=> $b} keys %$href) {
	    $tmpstr .= $href->{$key}{$i} . ',';
	}
	chop $tmpstr;
	$tmpstr .= ")\n";
	print $fh $tmpstr;
    }
    
    printf $fh "our_col <- rainbow(%d)\n", scalar @threads;
    print $fh "plot(x, y$threads[0], type=\"o\", pch=16, xlab=\"number of vertices\", ylab=\"time in seconds\", col=our_col[" . (1 + firstidx { $_ eq "0" } @threads) . "])\n";
    
    #~ print @threads, "\n";
    #~ print $fh "lines(x, y$threads[0], type=\"o\", col=our_col[" . (firstidx { $_ eq "1" } @threads) . "])\n";
    #~ print $fh 'mtext(side=1, line=-1, text="Here again?", adj=0, outer=T, col=our_col[' . (1 + firstidx { $_ eq $i } @threads) . "])\n";
    
    for my $i (@threads[1..$#threads]) {
	#~ print "\$i = $i ";
	#~ print $fh "mtext(side=1, line=-$i, text=\"$i threads\", adj=0, outer=T, col=our_col[" . (1 + firstidx { $_ eq $i } @threads) . "])\n";
	print $fh "lines(x, y$i, type=\"o\",pch=16, col=our_col[" . (1 + firstidx { $_ eq $i } @threads) . "])\n";
    }
    
    for my $i (@threads) {
	#~ print "\$i = $i ";
	my $adj = (firstidx { $_ eq $i } @threads) / @threads;
	print "\$i = $i \$adj = $adj \n";
	print $fh "mtext(side=1, line=-1, text=\"$i threads\", adj=$adj, outer=T, col=our_col[" . (1 + firstidx { $_ eq $i } @threads) . "])\n";
	#~ print $fh "lines(x, y$i, type=\"o\",pch=16, col=our_col[" . (1 + firstidx { $_ eq $i } @threads) . "])\n";
    }
    
    #~ print $fh "dev.off()\n";

    `Rscript $filename`;
    
    #~ copy($filename, "tmp.txt") or die "Copy failed: $!";
}
