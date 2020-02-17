#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
    print "usage: $0 <ifn1> <ifn2> <ofn paired R1> <ofn paired R2> <ofn non-paired R1> <ofn non-paired R2>\n";
	exit 1;
}

my $ifn1 = $ARGV[0];
my $ifn2 = $ARGV[1];
my $ofn_paired_R1 = $ARGV[2];
my $ofn_paired_R2 = $ARGV[3];
my $ofn_non_paired_R1 = $ARGV[4];
my $ofn_non_paired_R2 = $ARGV[5];

###########################################################################
# gather all reads into memory
###########################################################################

my %reads;
my $key = "";
foreach my $side ("R1", "R2") {
    my $ifn = ($side eq "R1") ? $ifn1 : $ifn2;
    my $iindex = 0;
    print "reading file: $ifn\n";
    open(IN, $ifn) or die;
    while (my $line = <IN>) {
	chomp($line);
	my $line_index = $iindex++ % 4;
	if ($line_index == 0) {
	    my $space_index = index($line, " ");
	    $space_index != -1 or die "expecting to find space in first line of fastq read: $line";
	    $key = substr($line, 0, $space_index);
	    $reads{$key}->{$side} = {};
	}
	$reads{$key}->{$side}->{$line_index} = $line;
    }
    close(IN);
}

print "writing file: $ofn_paired_R1\n";
print "writing file: $ofn_non_paired_R1\n";
open(OUT_PAIRED_R1, ">", $ofn_paired_R1);
open(OUT_NON_PAIRED_R1, ">", $ofn_non_paired_R1);

print "writing file: $ofn_paired_R2\n";
print "writing file: $ofn_non_paired_R2\n";
open(OUT_PAIRED_R2, ">", $ofn_paired_R2);
open(OUT_NON_PAIRED_R2, ">", $ofn_non_paired_R2);

# stats
my $paired_count = 0;
my $R1_count = 0;
my $R2_count = 0;
my $mismatch_count = 0;

foreach my $key (keys %reads) {
    my $R1 = defined($reads{$key}->{R1});
    my $R2 = defined($reads{$key}->{R2});
    if ($R1 && $R2) {
	if ( (length($reads{$key}->{R1}->{1}) != length($reads{$key}->{R1}->{3})) ||
	     (length($reads{$key}->{R2}->{1}) != length($reads{$key}->{R2}->{3})) ) {
	    $mismatch_count++;
	    next;
	}

	for (my $i=0; $i<4; $i++) {
	    print OUT_PAIRED_R1 $reads{$key}->{R1}->{$i}, "\n";
	    print OUT_PAIRED_R2 $reads{$key}->{R2}->{$i}, "\n";
	}
	$paired_count++;
    } elsif ($R1) {
	for (my $i=0; $i<4; $i++) {
	    print OUT_NON_PAIRED_R1 $reads{$key}->{R1}->{$i}, "\n";
	}
	$R1_count++;
    } else {
	for (my $i=0; $i<4; $i++) {
	    print OUT_NON_PAIRED_R2 $reads{$key}->{R2}->{$i}, "\n";
	}
	$R2_count++;
    }
}

print "number of paired reads: $paired_count\n";
print "number of only-R1 reads: $R1_count\n";
print "number of only-R2 reads: $R2_count\n";
print "number of mismatch reads: $mismatch_count\n";

close(OUT_PAIRED_R1);
close(OUT_NON_PAIRED_R1);
close(OUT_PAIRED_R2);
close(OUT_NON_PAIRED_R2);
