#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <ifn> <max_reads> <rnd seed> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $max_reads = $ARGV[1];
my $seed = $ARGV[2];
my $ofn = $ARGV[3];

srand($seed);

# first round: count 
open(IN, $ifn) or die;
my $lcount = 0;
while (my $line = <IN>) {
    $lcount++;
}
close(IN);

print "max reads: $max_reads\n";

my $rcount = $lcount / 4.0;
my $frac = $max_reads / $rcount;
$frac = 1 if ($frac > 1);
print "input reads: $rcount\n";
print "sub-sample fraction: $frac\n";

open(OUT, ">", $ofn) or die;
print "output file: $ofn\n";

# first round: count 
open(IN, $ifn) or die;
my $iindex = 0;
my $keep = 1;
$rcount = 0;
while (my $line = <IN>) {
    chomp($line);
    if ($iindex % 4 == 0) {
	$keep = (rand() < $frac);
	$rcount += $keep;
    }
    $iindex++;
    print OUT $line, "\n" if ($keep);
}
print "output reads: $rcount\n";

close(IN);
close(OUT);
