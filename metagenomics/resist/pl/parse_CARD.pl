#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <aro> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $aro = $ARGV[1];
my $ofn = $ARGV[2];

###################################################################################################################
# read genes
###################################################################################################################

my %clusters;
my $cluster = 0;
my $index = 0;

print "writing output: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "aro\tcluster\tindex\tsubject\tgene\tidentity\n";

print "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;
while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) eq ">") {
	$cluster++;
	$clusters{$cluster} = {};
	$index = 0;
	next
    }
    my @f = split('\s+', $line);
    # print join(":", @f), "\n";
    my $item = substr($f[2], 1);
    my $identity = 100;
    $index++;

    my $i1 = index($item, "g");
    my $i2 = index($item, ".");
    my $subject = substr($item, 0, $i1-1);
    my $gene = substr($item, $i1, $i2-$i1);

    if ($f[3] ne "*") {
	$identity = $f[4];
	my $i1 = index($identity, "/");
	my $i2 = index($identity, "%");
	$identity = substr($identity, $i1+1, $i2-$i1-1);
    }
    print OUT $aro, "\t", $cluster, "\t", $index, "\t", $subject, "\t", $gene, "\t", $identity, "\n";

}

close(OUT);
