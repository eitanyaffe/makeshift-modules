#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
	print STDERR "usage: $0 <binary> <filename suffix> <output file> <complexity ofn> <stats ofn> <input dir1 dir2 ...>\n";
	exit 1;
}

my $bin = $ARGV[0];
my $suffix = $ARGV[1];
my $ofn = $ARGV[2];
my $ofn_complex = $ARGV[3];
my $ofn_stats = $ARGV[4];
shift; shift; shift; shift; shift;
my @idirs = @ARGV;

my $command = sprintf("%s -ofn %s -mfn %s -sfn %s", $bin, $ofn, $ofn_complex, $ofn_stats);
print STDERR "Input dirs: ", join(" ", @idirs), "\n";
foreach my $idir (@idirs) {
    print STDERR "looking for files matching: $idir/*$suffix\n";
    my @ifns = <$idir/*$suffix>;
    @ifns > 0 or die "no files in $idir";

    foreach my $ifn (@ifns) {
	$command .= " -ifn ".$ifn;
    }
}
print "command: $command\n";
system($command) == 0 or die;
