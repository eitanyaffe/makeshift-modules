#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

print "gene\tcontig\tstart\tend\tstrand\tlength\taa_length\tscore\n";
while (my $line = <STDIN>) {
    chomp($line);
    next if (substr($line, 0, 1) eq "#");
    my @f = split("\t", $line);
    my $contig = $f[0];
    my $start = $f[3];
    my $end = $f[4];
    my $strand = $f[6];
    my $score = $f[5];
    my @f1 = split(";",$f[8]);
    my @f2 = split("=",$f1[0]);
    my $gene = "g".$f2[1];

    my $length = $end - $start + 1;
    my $aa_length = $length/3;

    print "$gene\t$contig\t$start\t$end\t$strand\t$length\t$aa_length\t$score\n";
}



