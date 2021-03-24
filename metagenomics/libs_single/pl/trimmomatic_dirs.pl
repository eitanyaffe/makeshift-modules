#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <trimmo jar> <trimmo mode> <trimmo threads> <trimmo params> <filename suffix> <output dir> <input dir1 dir2 ...>\n";
	exit 1;
}

my $jar = $ARGV[0];
my $mode = $ARGV[1];
my $threads = $ARGV[2];
my $params = $ARGV[3];
my $suffix = $ARGV[4];
my $odir = $ARGV[5];
shift; shift; shift; shift; shift; shift;
my @idirs = @ARGV;

print STDERR "Input dirs: ", join(" ", @idirs), "\n";
foreach my $idir (@idirs) {
    print STDERR "looking for files matching: $idir/*$suffix\n";
    my @ifns = <$idir/*$suffix>;
    @ifns > 0 or die "no files in $idir";

    my %pfiles;
    for my $ifn (@ifns) {
	my $side = (index($ifn, "R1") != -1) ? "R1" : "R2";
	my $fkey = $ifn;
	$fkey =~ s/R[12]//;
	$pfiles{$fkey}->{$side} = $ifn;
    }

    foreach my $fkey (keys %pfiles) {
	defined($pfiles{$fkey}->{R1}) && defined($pfiles{$fkey}->{R2}) or die "prefix doesn't have two sides: $fkey";
	my $ifn1 = $pfiles{$fkey}->{R1};
	my $ifn2 = $pfiles{$fkey}->{R2};
	my $ofn1 = $odir."/".basename($ifn1);
	my $ofn2 = $odir."/".basename($ifn2);
	my $command = sprintf("java -jar %s %s -threads %s", $jar, $mode, $threads);
	$command .= sprintf(" %s %s", $ifn1, $ifn2);
	$command .= sprintf(" %s /dev/null", $ofn1);
	$command .= sprintf(" %s /dev/null", $ofn2);
	$command .= sprintf(" %s", $params);
	print "command: $command\n";
	system($command) == 0 or die;
    }
}
