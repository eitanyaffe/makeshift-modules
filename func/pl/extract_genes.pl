#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn gene table> <ifn fasta> <ofn>\n";
	exit 1;
}

my $ifn_genes = $ARGV[0];
my $ifn_fasta = $ARGV[1];
my $ofn = $ARGV[2];

#######################################################################################
# get genes
#######################################################################################

my %genes;

print STDERR "traversing file: $ifn_genes\n";
open(IN, $ifn_genes) || die $ifn_genes;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    $genes{$f[$h{gene}]} = 1;
}
close(IN);

#######################################################################################
# output selected genes
#######################################################################################

print STDERR "traversing file: $ifn_fasta\n";
open(IN, $ifn_fasta) || die $ifn_fasta;

print STDERR "creating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

my $selected = 0;
while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) eq ">") {
	my $gene = substr($line, 1);
	$selected = defined($genes{$gene});
    }
    print OUT "$line\n" if ($selected);
}
close(IN);
close(OUT);

#######################################################################################
# utils
#######################################################################################

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
