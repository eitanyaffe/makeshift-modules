#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <output table> <output dir> <max number of reads> <should trim> <trim read offset> <trim read length> <input fastq R1> <input fastq R2>\n";
	exit 1;
}

my $ofn = $ARGV[0];
my $odir = $ARGV[1];
my $max_reads = $ARGV[2];
my $trim = $ARGV[3] eq "T";
my $offset = $ARGV[4];
my $rlen = $ARGV[5];
my $ifn1 = $ARGV[6];
my $ifn2 = $ARGV[7];

my $oindex = 1;

my $ofn1 = $odir."/".$oindex."_R1.fastq";
my $ofn2 = $odir."/".$oindex."_R2.fastq";

open(OUT1, ">", $ofn1) or die;
open(OUT2, ">", $ofn2) or die;
print "output file: $ofn1\n";
print "output file: $ofn2\n";

my $read_count = 0;
open(IN1, $ifn1) or die;
open(IN2, $ifn2) or die;

my %chunks;
my $iindex = 0;
while () {
    my $line1 = <IN1>;
    my $line2 = <IN2>;
    
    last if (!defined($line1) || !defined($line2));
    
    chomp($line1);
    chomp($line2);
    
    $line1 = substr($line1, $offset, $rlen) if ($trim && $iindex % 2 == 1);
    $line2 = substr($line2, $offset, $rlen) if ($trim && $iindex % 2 == 1);
    $iindex++;
    
    print OUT1 $line1, "\n";
    print OUT2 $line2, "\n";
    
    if ($iindex % 4 == 0) {
	$read_count++;
	
	if ($read_count >= $max_reads) {
	    $chunks{$oindex} = $read_count;
	    $read_count = 0;
	    close(OUT1);
	    close(OUT2);
	    $oindex++;
	    
	    $ofn1 = $odir."/".$oindex."_R1.fastq";
	    $ofn2 = $odir."/".$oindex."_R2.fastq";
	    
	    open(OUT1, ">", $ofn1) or die;
	    open(OUT2, ">", $ofn2) or die;
	    print "output file: $ofn1\n";
	    print "output file: $ofn2\n";
	    
	}
    }
}
close(IN1);
close(IN2);

close(OUT1);
close(OUT2);

$chunks{$oindex} = $read_count;

# chunk table
print "output chunk table: $ofn\n";
open(OUT, ">", $ofn) or die;
print OUT "chunk\treads\n";
foreach my $oindex (sort { $a <=> $b } keys %chunks) {
    print OUT $oindex, "\t", $chunks{$oindex}, "\n";
}
close(OUT);
