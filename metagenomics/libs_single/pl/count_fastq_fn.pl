#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <input R1> <input R2> <output title> <output file>\n";
	exit 1;
}

my $ifn1 = $ARGV[0];
my $ifn2 = $ARGV[1];
my $title = $ARGV[2];
my $ofn = $ARGV[3];

my ($read_count1, $bp_count1) = parse_file($ifn1);
my ($read_count2, $bp_count2) = parse_file($ifn2);

open(OUT, ">", $ofn) or die;
print OUT $title, "\t", "R1", "\t", $read_count1, "\t", $bp_count1, "\n";
print OUT $title, "\t", "R2", "\t", $read_count2, "\t", $bp_count2, "\n";
close(OUT);

sub parse_file
{
    my ($ifn) = @_;
    my ($read_count, $bp_count) = (0,0);
    open(IN, $ifn) or die;
    my $l_count = 0;
    while (my $line = <IN>) {
	if ($l_count % 4 == 1) {
	    chomp($line);
	    $bp_count += length($line);
	    $read_count++;
	}
	$l_count++;
    }
    return ($read_count, $bp_count);
}
