#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
	print "usage: $0 <output> <pattern> <input dir1 dir2 ...>\n";
	exit 1;
}

my $ofn = $ARGV[0];
my $pattern = $ARGV[1];
shift; shift;
my @idirs = @ARGV;

my %pfiles;
print "Input dirs: ", join(" ", @idirs), "\n";
foreach my $idir (@idirs) {
    print "looking for files matching: $idir/$pattern\n";
    my @ifns = <$idir/$pattern>;
    @ifns > 0 or die "no files in $idir";

    for my $ifn (@ifns) {
	my $side = (index($ifn, "R1") != -1) ? "R1" : "R2";
	my $fkey = $ifn;
	$fkey =~ s/R[12]//;
	$pfiles{$fkey}->{$side} = $ifn;
    }
}

print "generating yaml file: $ofn\n";
open(OUT, ">", $ofn) or die;
print OUT "[ {\n";
print OUT "orientation: \"fr\",\n";
print OUT "type: \"paired-end\",\n";

my @fkeys = keys %pfiles;
my $last_key = $fkeys[-1];

print OUT "left reads: [\n";
foreach my $fkey (@fkeys) {
    defined($pfiles{$fkey}->{R1}) && defined($pfiles{$fkey}->{R2}) or die "prefix doesn't have two sides: $fkey";
    my $ifn = $pfiles{$fkey}->{R1};
    print OUT "  \"$ifn\"";
    print OUT "," if ($fkey ne $last_key);
    print OUT "\n";

}
print OUT "],\n";

print OUT "right reads: [\n";
foreach my $fkey (@fkeys) {
    defined($pfiles{$fkey}->{R1}) && defined($pfiles{$fkey}->{R2}) or die "prefix doesn't have two sides: $fkey";
    my $ifn = $pfiles{$fkey}->{R2};
    print OUT "  \"$ifn\"";
    print OUT "," if ($fkey ne $last_key);
    print OUT "\n";

}
print OUT "]\n";

print OUT "} ]\n";

close(OUT);
