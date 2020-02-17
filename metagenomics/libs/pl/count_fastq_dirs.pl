#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <prefix pattern> <suffix pattern> <output title> <output file> <input dirs ...>\n";
	exit 1;
}

my $pre_pattern = $ARGV[0];
my $suf_pattern = $ARGV[1];
my $title = $ARGV[2];
my $ofn = $ARGV[3];
shift; shift; shift; shift;
my @idirs = @ARGV;

my @ifns1;
my @ifns2;

print STDERR "Input dirs: ", join(" ", @idirs), "\n";
foreach my $idir (@idirs) {
    my $p1 = $pre_pattern."R1".$suf_pattern;
    my $p2 = $pre_pattern."R2".$suf_pattern;

    push(@ifns1, <$idir/$p1>);
    push(@ifns2, <$idir/$p2>);
}
scalar(@ifns1) > 0 && scalar(@ifns2) > 0 or die "no files found";

print "side1 files: ", join(",", @ifns1), "\n";
print "side2 files: ", join(",", @ifns2), "\n";

my ($read_count1, $bp_count1) = parse_files(\@ifns1);
my ($read_count2, $bp_count2) = parse_files(\@ifns2);

print STDERR "Generating file: ", $ofn, "\n";
open(OUT, ">", $ofn) or die;
print OUT $title, "\t", "R1", "\t", $read_count1, "\t", $bp_count1, "\n";
print OUT $title, "\t", "R2", "\t", $read_count2, "\t", $bp_count2, "\n";
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
