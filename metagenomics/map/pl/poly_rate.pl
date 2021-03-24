#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <contig table> <nt_table> <max percentage> <ofn>\n";
	exit 1;
}

my $ifn_contig = $ARGV[0];
my $ifn = $ARGV[1];
my $max_perc = $ARGV[2];
my $ofn = $ARGV[3];

###############################################################################################
# setup contig bins
###############################################################################################

my %contigs;
print STDERR "reading contig table: $ifn_contig\n";
open(IN, $ifn_contig) || die $ifn_contig;
my $header = <IN>;
my %h = parse_header($header);

my @types = ("snp", "insert", "delete", "dangle");

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $length = $f[$h{length}];
    $contigs{$contig} = {};
    $contigs{$contig}->{length} = $length;
    $contigs{$contig}->{poly_count} = 0;
    $contigs{$contig}->{total_coverage} = 0;
}

###############################################################################################
# traverse all reads
###############################################################################################

open(IN, $ifn) || die $ifn;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $type = $f[$h{type}];
    my $count = $f[$h{count}];
    my $perc = $f[$h{percent}];
    next if (!defined($contigs{$contig}));
    next if ($perc >= $max_perc || $type ne "REF");
    $contigs{$contig}->{poly_count}++;
    $contigs{$contig}->{total_coverage} += $count;
}
close(IN);

###############################################################################################
# output
###############################################################################################

open(OUT, ">", $ofn) || die $ofn;
print STDERR "generating file: $ofn\n";
print OUT "contig\tlength\tpoly\tpoly_per_bp\tmean_coverage\n";
foreach my $contig (sort keys %contigs) {
    my $length = $contigs{$contig}->{length};
    my $poly = $contigs{$contig}->{poly_count};
    my $poly_per_bp = $poly / $length;
    my $mean_coverage = $contigs{$contig}->{poly_count} > 0 ? $contigs{$contig}->{total_coverage} / $contigs{$contig}->{poly_count} : 0;

    print OUT $contig, "\t", $length, "\t", $poly, "\t", $poly_per_bp, "\t", $mean_coverage, "\n";
}
close(OUT);

######################################################################################################
# Subroutines
######################################################################################################


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
