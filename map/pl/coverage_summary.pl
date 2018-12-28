#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <contig table> <input dir> <binsize> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $field = $ARGV[1];
my $idir = $ARGV[2];
my $binsize = $ARGV[3];
my $ofn = $ARGV[4];

my %contigs;

###############################################################################################
# setup contig bins
###############################################################################################

print "reading contig table: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{$field}];
    my $contig_length = $f[$h{length}];
    my $nbins = ceil($contig_length / $binsize) + 1;
    $contigs{$contig} = {};
    $contigs{$contig}->{length} = $contig_length;
    $contigs{$contig}->{count} = 0;
    $contigs{$contig}->{bins} = [(0) x $nbins];
}

###############################################################################################
# traverse all reads
###############################################################################################

print "Input dir: $idir\n";
my @ifns = <$idir/*>;

print "number of input files: ", scalar(@ifns), "\n";

foreach my $ifn (@ifns) {
    next if (basename($ifn) eq "files");
    print ".";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    my %h = parse_header($header);
    while (my $line = <IN>) {
	chomp $line;
	my @f = split("\t", $line);
	my $contig = $f[$h{contig}];
	my $coord = $f[$h{coord}];
	my $bin = floor(($coord-1) / $binsize);

	# sanity checks
	next if (!defined($contigs{$contig}));
	$bin >= 0 && $bin < scalar(@{$contigs{$contig}->{bins}}) or die $line, "\n", $contig, ":", $coord;

	$contigs{$contig}->{bins}->[$bin] += 1;
	$contigs{$contig}->{count} += 1;
    }
    close(IN);
}
print "\n";

print "generating table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "contig\tlength\tcount\tdensity\tmedian_density\n";
foreach my $contig (keys %contigs) {
    my $length = $contigs{$contig}->{length};
    my $count = $contigs{$contig}->{count};
    my $density = $count / $length;

    # compute median density
    my $nbins = scalar(@{$contigs{$contig}->{bins}});
    my @contig_values;
    for (my $i = 0; $i < $nbins; $i++) {
	my $count = $contigs{$contig}->{bins}->[$i];
	push(@contig_values, $count);
    }
    my $median_value = median(@contig_values);
    my $median_density = $median_value / $binsize;

    print OUT $contig, "\t", $length, "\t", $count, "\t", $density, "\t", $median_density, "\n";
}
close(OUT);

######################################################################################################
# Subroutines
######################################################################################################

sub sum {
    my $sum = 0;
    for ( @_ ) {
	$sum += $_;
    }
    $sum;
}

sub median {
  sum( ( sort { $a <=> $b } @_ )[ int( $#_/2 ), ceil( $#_/2 ) ] )/2;
}

sub parse_header
{
	my ($header) = @_;
	chomp($header);
	my @f = split("\t", $header);
	my %result;
	for (my $i = 0; $i <= $#f; $i++) {
		$result{$f[$i]} = $i;
	}
	return %result;
}
