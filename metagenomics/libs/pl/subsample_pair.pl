#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <mean_reads> <rnd seed> <input R1> <input R2> <output R1> <output R2>\n";
	exit 1;
}

my $mean_reads = $ARGV[0];
my $seed = $ARGV[1];
my $ifn1 = $ARGV[2];
my $ifn2 = $ARGV[3];
my $ofn1 = $ARGV[4];
my $ofn2 = $ARGV[5];
my $ofn_stats = $ARGV[6];

srand($seed);

###############################################################
# first round: count 
###############################################################

open(IN, $ifn1) or die;
my $lcount = 0;
while (my $line = <IN>) {
    $lcount++;
}
close(IN);

my $total_read_count = $lcount / 4.0;
my $frac = $mean_reads / $total_read_count;
$frac = 1 if ($frac > 1);

###############################################################
# second round: sub-sample 
###############################################################

open(IN1, $ifn1) or die;
open(IN2, $ifn2) or die;

open(OUT1, ">", $ofn1) or die;
open(OUT2, ">", $ofn2) or die;

my $iindex = 0;
my $keep = 1;
my $keep_read_count = 0;
while (1) {
    my $line1 = <IN1>;
    my $line2 = <IN2>;
    last if (!defined($line1) || !defined($line2));
    chomp($line1);
    chomp($line2);
    
    if ($iindex % 4 == 0) {
	$keep = (rand() <= $frac);
	$keep_read_count += $keep;
    }
    $iindex++;
    
    if ($keep) {
	print OUT1 $line1, "\n";
	print OUT2 $line2, "\n";
    }
}

close(IN1);
close(IN2);

close(OUT1);
close(OUT2);

open(OUT, ">", $ofn_stats) or die;
print OUT "in_reads\tout_reads\n";
print OUT $total_read_count, "\t", $keep_read_count, "\n";
close(OUT);
