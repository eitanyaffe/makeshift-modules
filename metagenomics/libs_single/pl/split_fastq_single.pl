#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <output dir> <max number of reads> <should trim> <trim read offset> <trim read length> <input fastq files>\n";
	exit 1;
}

my $odir = $ARGV[0];
my $max_reads = $ARGV[1];
my $trim = $ARGV[2] eq "T";
my $offset = $ARGV[3];
my $rlen = $ARGV[4];
shift; shift; shift; shift; shift;
my @ifns = @ARGV;

my $oindex = 1;

my $ofn = $odir."/R_".$oindex.".fastq";

open(OUT, ">", $ofn) or die;
print "output file: $ofn\n";

my $read_count = 0;
foreach my $ifn (@ifns) {
    open(IN, $ifn) or die;

    my $iindex = 0;
    while () {
	my $line = <IN>;
	last if (!defined($line));
	chomp($line);
	$line = substr($line, $offset, $rlen) if ($trim && $iindex % 2 == 1);
 	$iindex++;
	print OUT $line, "\n";

	if ($iindex % 4 == 0) {
	    $read_count++;

	    if ($read_count >= $max_reads) {
		$read_count = 0;
		close(OUT);
		$oindex++;

		$ofn = $odir."/R_".$oindex.".fastq";

		open(OUT, ">", $ofn) or die;
		print "output file: $ofn\n";
	    }
	}
    }
}
close(OUT);
