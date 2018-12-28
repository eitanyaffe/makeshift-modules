#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <nt_table> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $ofn = $ARGV[1];

###############################################################################################
# traverse all reads
###############################################################################################

my %contigs;
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $type = $f[$h{type}];
    my $count = $f[$h{count}];
    my $nt = $f[$h{sequence}];
    $contigs{$contig} = {} if (!defined($contigs{$contig}));
    if (!defined($contigs{$contig}->{$coord})) {
	$contigs{$contig}->{$coord} = {};
	$contigs{$contig}->{$coord}->{REF} = 0;
	$contigs{$contig}->{$coord}->{A} = 0;
	$contigs{$contig}->{$coord}->{C} = 0;
	$contigs{$contig}->{$coord}->{G} = 0;
	$contigs{$contig}->{$coord}->{T} = 0;
    }

    $contigs{$contig}->{$coord}->{REF} = $count if ($type eq "REF");
    $contigs{$contig}->{$coord}->{$nt} = $count if ($type eq "snp");
}
close(IN);

###############################################################################################
# output
###############################################################################################

open(OUT, ">", $ofn) || die $ofn;
print STDERR "generating file: $ofn\n";
print OUT "contig\tcoord\tREF\tA\tC\tG\tT\n";
foreach my $contig (sort keys %contigs) {
foreach my $coord (sort keys %{$contigs{$contig}}) {
    print OUT $contig, "\t", $coord, "\t";
    print OUT $contigs{$contig}->{$coord}->{REF}, "\t";
    print OUT $contigs{$contig}->{$coord}->{A}, "\t";
    print OUT $contigs{$contig}->{$coord}->{C}, "\t";
    print OUT $contigs{$contig}->{$coord}->{G}, "\t";
    print OUT $contigs{$contig}->{$coord}->{T}, "\n";
} }
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
