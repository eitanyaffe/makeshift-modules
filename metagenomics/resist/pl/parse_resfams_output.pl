#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;
$| = 1;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <ofn>\n";
	exit 1;
}

my ($ifn, $ofn) = @ARGV;

print "input file: $ifn\n";
open(IN, $ifn) || die $ifn;

print "output file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

my $header = "target\ttarget_accession\tquery\tquery_accession\tfull_Evalue\tfull_score\tfull_bias\tdomain_Evalue\tdomain_score\tdomain_bias\texp\treg\tclu\tov\tenv\tdom\trep\tinc\tdescription";
print OUT $header, "\n";

while (my $line = <IN>) {
    chomp($line);
    next if (substr($line,0,1) eq "#");
    $line =~ s/\s+/\t/g;
    print OUT $line, "\n";
}
close(IN);
close(OUT);
