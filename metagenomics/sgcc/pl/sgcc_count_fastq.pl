#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <input fastq> <output title> <output file>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $title = $ARGV[1];
my $ofn = $ARGV[2];

my ($read_count, $bp_count) = parse_file($ifn);

open(OUT, ">", $ofn) or die;
print OUT $title, "\t", $read_count, "\t", $bp_count, "\n";
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
