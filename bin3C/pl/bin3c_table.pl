#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
        print STDERR "usage: $0 <input dir> <fasta extension> <ofn>\n";
        exit 1;
}

my $idir = $ARGV[0];
my $ext = $ARGV[1];
my $ofn = $ARGV[2];

print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "cluster\tindex\tcontig\tlength\n";

my @ifns = <$idir/*$ext>;
foreach my $ifn (@ifns) {
    # print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;

    my $contig = "";
    while (my $line = <IN>) {
	chomp($line);
	if (substr($line, 0, 1) eq ">") {
	    my @f = split(" ", substr($line,1));

	    # cluster_index
	    my @f0 = split("_", $f[0]);
	    my $cluster = $f0[0];
	    my $index = int($f0[1]);

	    # x:contig
	    my @f1 = split(":", $f[1]);
	    my $contig = $f1[1];

	    # x:length
	    my @f3 = split(":", $f[3]);
	    my $length = $f3[1];

	    print OUT $cluster, "\t", $index, "\t", $contig, "\t", $length, "\n";
	}
    }
    close(IN);
}
close(OUT);



