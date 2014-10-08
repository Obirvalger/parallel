#! /usr/bin/perl

use v5.14;
use warnings;

$, = " ";

my @threads = (8); #array of numbers of threads for parallel program
my $n = my $begin = 600;
my $n_steps = 5;
my $step = 50;
my %result;
my ($outfile, $pdf_table_file, $pdf_plot_file, $data_file) = qw /output.txt table.pdf myplot.pdf outfile.txt/;
my ($write_pdf_table, $write_pdf_plot, $read_data_file) = (0, 0,0);

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
    elsif (s/^\s*pdf_plot_file\s*=\s*(["']?)([\.\d\w\s]*[\.\d\w])\1.*/$2/x) {$pdf_plot_file = $_}
    elsif (s/^\s*data_file\s*=\s*(["']?)([\.\d\w\s]*[\.\d\w])\1.*/$2/x) {$data_file = $_}
    elsif (s/^\s*threads\s*=\s*[\[\(]?([\d\s,]+)[\]\)]?.*/$1/) {@threads = split /[\s,]*/}
    elsif (s/^\s*write_pdf_table\s*=\s*(\d).*/$1/) {$write_pdf_table = $_}
    elsif (s/^\s*write_pdf_plot\s*=\s*(\d).*/$1/) {$write_pdf_plot = $_}
    elsif (s/^\s*read_data_file\s*=\s*(\d).*/$1/) {$read_data_file = $_}
    #~ print "$&; $outfile\n";
}

unless ($read_data_file) {
    open(my $fh, ">", $outfile)
	or die "cannot open > $outfile $!";

    `make test test_p`;

    printf $fh "N 1 ";
    for (@threads) {
	printf $fh "$_ ";
    }
    print $fh "\n";

    for my $i (1 .. $n_steps) {
	my %times;
	chomp($times{1} = qx(./test $n));
	for my $j (@threads) {
	    chomp($times{$j} = qx(./test_p $n $j));
	}
	$result{$n} = \%times;
	printf "step = $i/$n_steps  n = $n  maxtime = %f  mintime = %f\n", $times{1}, $times{$threads[-1]};
	printf $fh "%d ", $n;
	for my $key (sort {$a <=> $b} keys %times) {
	    printf $fh ("%f ", $times{$key});
	    #~ printf $fh ("%d=%f ", $k2, $times{$key});
	}
	print $fh "\n";
    
	$n += $step;
    }

    close $fh;
} else {
    &read_result(\%result, $data_file);
}

&make_pdf_table(\%result, $pdf_table_file) if $write_pdf_table;
&make_pdf_plot(\%result, $pdf_plot_file) if $write_pdf_plot;

sub read_result {
    use Data::Dumper qw(Dumper);
    
    my ($href, $fname) = @_;
    my $fh;
    open($fh, "<", $fname)
	or die "cannot open < $fname $!";
    local $_ = <$fh>;
    my @threads = /\d+/g;
    #~ print "@threads\n";
    while (<$fh>) {
	my @args = /\d+\.?\d*/g;
	#~ print @args, "\n";
	die "wrong number of arguments in $. string:\n$_" if ($#args != $#threads + 1);
	for (my $i = 0; $i < @threads; ++$i) {
	    $href -> {$args[0]}{$threads[$i]} = $args[$i + 1];
	}
    }
    
    #~ print Dumper $href;
    
}


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
	    $beg .= '|l|';
	    $hline .= " & " . ($k2 == 1 ? '1 thread' : "$k2 threads");
	}
    $beg .= "}\n";
    $hline .= "\\\\ \\hline \\hline \n";
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
    #~ print $fh "\\caption{Results}\n\\label{results_functions}\n";
    print $fh $end;
    
    print $fh "\n";
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
    #~ my $max_val;
    my @threads = sort {$a <=> $b} keys %{$href -> {(keys %$href)[0]}};
    #~ print "threads " . join(', ', @threads) . "\n";
    
    print $fh 'pdf(file="myplot.pdf")' . "\n";
    print $fh "par(mar=c(4, 4, 1, 1))\n";
    
    $tmpstr = "x <- c(";
    $tmpstr .= join(',', (sort {$a <=> $b} keys %$href));
    $tmpstr .= ")\n";
    print $fh $tmpstr;
    
    for my $i (@threads) {
	$tmpstr = "y$i <- c(";
	for my $key (sort {$a <=> $b} keys %$href) {
	    $tmpstr .= $href->{$key}{$i} . ',';
	    #~ $max_val = $href->{$key}{$i} if not defined($max_val) or $href->{$key}{$i} > $max_val;
	}
	chop $tmpstr;
	$tmpstr .= ")\n";
	print $fh $tmpstr;
    }
    
    printf $fh "our_col <- rainbow(%d)\n", scalar @threads;
    print $fh "plot(x, y$threads[0], type=\"o\", pch=16, xlab=\"number of vertices\", ylab=\"time in seconds\", col=our_col[" .
	(1 + firstidx { $_ eq "$threads[0]" } @threads) . "])\n";
    
    for my $x (@threads[1..$#threads]) {
	print $fh "lines(x, y$x, type=\"o\",pch=16, col=our_col[" . (1 + firstidx { $_ eq $x } @threads) . "])\n";
    }
    
    my $names = '';
    my $colors = '';
    for (my $i = 0; $i < @threads; ++$i) {
	$colors .= "our_col[" . $i . "]**";
	$names .= '"' . $threads[$i] . " thread" . ($threads[$i] == 1 ? '' : 's'). "\"**";
	#~ my $adj = (firstidx { $_ eq $x } @threads) / @threads;
	#~ print $fh "mtext(side=1, line=-1, text=\"$x threads\", adj=$adj, outer=T, col=our_col[" . (1 + firstidx { $_ eq $x } @threads) . "])\n";
    }
    
    $names = "c(" . join(",", split(/\*\*/, $names)) . ")";
    $colors = "c(" . join(",", split(/\*\*/, $colors)) . ")";
    #~ my $x_pos = (sort {$a <=> $b} keys %$href)[0];
    #~ my $y_pos = $max_val;
    #~ print $fh "legend($x_pos, $y_pos, $names, col=$colors, pch=rep.int(16," , scalar @threads, "))\n";
    print $fh "legend(\"topleft\", inset=.02, $names, fill=rainbow(" , scalar @threads, "))\n";

    print $fh "\n";
    `Rscript $filename`;
}
