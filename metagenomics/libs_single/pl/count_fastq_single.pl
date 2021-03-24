#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <input dir> <input prefix pattern> <input suffix pattern> <output title> <output file>\n";
	exit 1;
}

my $idir = $ARGV[0];
my $pre_pattern = $ARGV[1];
my $suf_pattern = $ARGV[2];
my $title = $ARGV[3];
my $ofn = $ARGV[4];

print "computing stats in $title directory: $idir\n";
print "prefix pattern: $pre_pattern\n";
print "suffix pattern: $suf_pattern\n";

my $p = $pre_pattern.$suf_pattern;

my @ifns = <$idir/$p>;

print "files: ", join(",", @ifns), "\n";

my ($read_count, $bp_count) = parse_files(\@ifns);

open(OUT, ">", $ofn) or die;
print OUT $title, "\t", "R", "\t", $read_count, "\t", $bp_count, "\n";
close(OUT);

sub parse_files
{
    my ($ref) = @_;
    my @ifns = @{ $ref };
    my ($read_count, $bp_count) = (0,0);
    foreach my $ifn (@ifns) {
	next if (index($ifn, "~") != -1);
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
    }
    return ($read_count, $bp_count);
}
