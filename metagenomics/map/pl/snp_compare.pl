#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn1> <ifn2> <ofn>\n";
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
    my $seq = $f[$h{sequence}];
    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{count} = 0;
	$contigs{$contig}->{coords} = {};
    }
    $contigs{$contig}->{coords}->{$coord} = {};
    $contigs{$contig}->{coords}->{$coord}->{seq1} = $seq;
    $contigs{$contig}->{coords}->{$coord}->{seq2} = "REF";
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
    my $seq = $f[$h{sequence}];
    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{count} = 0;
	$contigs{$contig}->{coords} = {};
    }
    if (!defined($contigs{$contig}->{coords}->{$coord})) {
	$contigs{$contig}->{coords}->{$coord} = {};
	$contigs{$contig}->{coords}->{$coord}->{seq1} = "REF";
    }
    $contigs{$contig}->{coords}->{$coord}->{seq2} = $seq;
}
close(IN);

###############################################################################################
# summary
###############################################################################################

foreach my $contig (sort keys %contigs) {
foreach my $coord (sort keys %{$contigs{$contig}->{coords}}) {
    next if ($contigs{$contig}->{coords}->{$coord}->{seq1} eq $contigs{$contig}->{coords}->{$coord}->{seq2});
    $contigs{$contig}->{count}++;
} }

###############################################################################################
# output
###############################################################################################

open(OUT, ">", $ofn) || die $ofn;
print STDERR "generating file: $ofn\n";
print OUT "contig\tcount\n";
foreach my $contig (sort keys %contigs) {
    print OUT $contig, "\t", $contigs{$contig}->{count}, "\n";
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
