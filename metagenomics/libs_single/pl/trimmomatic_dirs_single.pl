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

    foreach my $ifn (@ifns) {
	my $ofn = $odir."/".basename($ifn);
	my $command = sprintf("java -jar %s %s -threads %s", $jar, $mode, $threads);
	$command .= sprintf(" %s %s", $ifn, $ofn);
	$command .= sprintf(" %s", $params);
	print "command: $command\n";
	system($command) == 0 or die;
    }
}
