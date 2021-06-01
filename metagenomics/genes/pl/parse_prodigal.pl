#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

print "gene\tcontig\tstart\tend\tstrand\tlength\taa_length\tscore\tpartial_start\tpartial_end\n";
while (my $line = <STDIN>) {
    chomp($line);
    next if (substr($line, 0, 1) eq "#");
    my @f = split("\t", $line);
    my $contig = $f[0];
    my $start = $f[3];
    my $end = $f[4];
    my $strand = $f[6];
    my $score = $f[5];

    # more data here
    my @ff = split(";",$f[8]);

    # gene id
    my $gene = "g".(split("=",$ff[0]))[1];

    # truncated
    (split("=",$ff[1]))[0] eq "partial" or die "expecting field 'partial'";
    my $partial_str = (split("=",$ff[1]))[1];
    my $partial_start = (($partial_str eq "10") || ($partial_str eq "11")) ? "T" : "F";
    my $partial_end = (($partial_str eq "01") || ($partial_str eq "11")) ? "T" : "F";

    my $length = $end - $start + 1;
    my $aa_length = $length/3;

    print "$gene\t$contig\t$start\t$end\t$strand\t$length\t$aa_length\t$score\t$partial_start\t$partial_end\n";
}



