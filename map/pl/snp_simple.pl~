#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <nt_table> <ofn>\n";
	exit 1;
}

my $ifn1 = $ARGV[0];
my $ifn2 = $ARGV[1];
my $ofn = $ARGV[2];

###############################################################################################
# traverse ifn1
###############################################################################################

my %contigs;
print STDERR "reading file: $ifn1\n";
open(IN, $ifn1) || die $ifn1;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    $contigs{$contig} = {} if (!defined($contigs{$contig}));
    $contigs{$contig}->{$coord} = {};
    $contigs{$contig}->{$coord}->{REF1} = $f[$h{REF}];
    $contigs{$contig}->{$coord}->{A1} = $f[$h{A}];
    $contigs{$contig}->{$coord}->{C1} = $f[$h{C}];
    $contigs{$contig}->{$coord}->{G1} = $f[$h{G}];
    $contigs{$contig}->{$coord}->{T1} = $f[$h{T}];
    $contigs{$contig}->{$coord}->{REF2} = -1;
    $contigs{$contig}->{$coord}->{A2} = -1;
    $contigs{$contig}->{$coord}->{C2} = -1;
    $contigs{$contig}->{$coord}->{G2} = -1;
    $contigs{$contig}->{$coord}->{T2} = -1;
}
close(IN);

###############################################################################################
# traverse ifn2
###############################################################################################

print STDERR "reading file: $ifn2\n";
open(IN, $ifn2) || die $ifn2;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    $contigs{$contig} = {} if (!defined($contigs{$contig}));
    if (!defined($contigs{$contig}->{$coord})) {
	$contigs{$contig}->{$coord} = {};
	$contigs{$contig}->{$coord}->{REF1} = -1;
	$contigs{$contig}->{$coord}->{A1} = -1;
	$contigs{$contig}->{$coord}->{C1} = -1;
	$contigs{$contig}->{$coord}->{G1} = -1;
	$contigs{$contig}->{$coord}->{T1} = -1;
    }

    $contigs{$contig}->{$coord}->{REF2} = $f[$h{REF}];
    $contigs{$contig}->{$coord}->{A2} = $f[$h{A}];
    $contigs{$contig}->{$coord}->{C2} = $f[$h{C}];
    $contigs{$contig}->{$coord}->{G2} = $f[$h{G}];
    $contigs{$contig}->{$coord}->{T2} = $f[$h{T}];
}
close(IN);

###############################################################################################
# output
###############################################################################################

open(OUT, ">", $ofn) || die $ofn;
print STDERR "generating file: $ofn\n";
print OUT "contig\tcoord\tREF1\tA1\tC1\tG1\tT1\tREF2\tA2\tC2\tG2\tT2\n";
foreach my $contig (sort keys %contigs) {
foreach my $coord (sort keys %{$contigs{$contig}}) {
    print OUT $contig, "\t", $coord, "\t";
    print OUT $contigs{$contig}->{$coord}->{REF1}, "\t";
    print OUT $contigs{$contig}->{$coord}->{A1}, "\t";
    print OUT $contigs{$contig}->{$coord}->{C1}, "\t";
    print OUT $contigs{$contig}->{$coord}->{G1}, "\t";
    print OUT $contigs{$contig}->{$coord}->{T1}, "\t";
    print OUT $contigs{$contig}->{$coord}->{REF2}, "\t";
    print OUT $contigs{$contig}->{$coord}->{A2}, "\t";
    print OUT $contigs{$contig}->{$coord}->{C2}, "\t";
    print OUT $contigs{$contig}->{$coord}->{G2}, "\t";
    print OUT $contigs{$contig}->{$coord}->{T2}, "\n";
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
