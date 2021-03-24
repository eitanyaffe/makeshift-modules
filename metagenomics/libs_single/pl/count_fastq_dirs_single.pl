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
my @ifns;

print STDERR "Input dirs: ", join(" ", @idirs), "\n";
foreach my $idir (@idirs) {
    my $p = $pre_pattern.$suf_pattern;
    push(@ifns1, <$idir/$p>);
}
print "files: ", join(",", @ifns), "\n";

my ($read_count, $bp_count) = parse_files(\@ifns);

print STDERR "Generating file: ", $ofn, "\n";
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
