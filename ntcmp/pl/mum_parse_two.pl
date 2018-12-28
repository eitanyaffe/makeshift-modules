#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

my $ofn = $ARGV[0];

my $qcontig = "";
my $qstrand = "+";
open(OUT, ">", $ofn);
print OUT "tcontig\ttstart\ttend\tqcontig\tqstart\tqend\tstrand\tlength\n";

while (my $line = <STDIN>) {
    chomp($line);
    my @f = split(/\s+/, $line);
    if (substr($line, 0, 1) eq ">") {
	$qcontig = $f[1];

	if (scalar(@f) == 2) {
	    $qstrand = "+";
	} else {
	    (scalar(@f) == 3 and $f[2] eq "Reverse") or die;
	    $qstrand = "-";
	}

    } else {
	$qcontig ne "" or die;
	my $length = $f[4];

	my $qstart = ($qstrand eq "+") ? $f[3] : ($f[3] - $length + 1);
	my $qend = $qstart + $length;

	my $tcontig = $f[1];
	my $tstart = $f[2];
	my $tend = $tstart + $length;

	print OUT "$tcontig\t$tstart\t$tend\t$qcontig\t$qstart\t$qend\t$qstrand\t$length\n";
    }
}
close(OUT);
