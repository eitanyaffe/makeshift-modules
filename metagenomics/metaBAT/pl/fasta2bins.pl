#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <fasta input dir> <output table>\n";
	exit 1;
}

my $idir = $ARGV[0];
my $ofn = $ARGV[1];

print ("reading fasta files in dir: $idir\n");
my @ifns = <$idir/*.fa>;
scalar(@ifns) > 0 or die "no files found";

print ("writing table: $ofn\n");
open(OUT, ">", $ofn) or die $ofn;
print OUT "bin\tcontig\n";

foreach my $ifn (@ifns) {
    
    open(IN, $ifn) or die $ifn;
    my $bin = basename($ifn);
    $bin =~ s/.fa//;
    $bin =~ s/bin.//;
    while (my $line = <IN>) {
	chomp($line);
	if (substr($line, 0, 1) eq ">") {
	    my $contig = substr($line,1);
	    print OUT $bin, "\t", $contig, "\n";
	}
    }
    close(IN);
}

close(OUT);



