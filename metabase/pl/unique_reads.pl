#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <input R1> <input R2>\n";
	exit 1;
}

my $ifn1 = $ARGV[0];
my $ifn2 = $ARGV[1];
open(IN1, $ifn1) or die;
open(IN2, $ifn2) or die;
my $l_count = 0;
my $count = 0;
my %hh;
while () {
    my $line1 = <IN1>;
    my $line2 = <IN2>;
    last if (eof(IN1));
    if ($l_count++ % 4 == 1) {
	$count++;
	chomp($line1);
	chomp($line2);
	my $key = $line1."_".$line2;
	$hh{$key} = 1;
    }
}
close(IN1);
close(IN2);

print "total reads: ", $count, "\n";
print "unique reads: ", scalar(keys %hh), "\n";
