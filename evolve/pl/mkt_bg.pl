#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;
use Switch;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn codon> <ifn gene> <ofn>\n";
	exit 1;
}

my $ifn_codon = $ARGV[0];
my $ifn_genes = $ARGV[1];
my $ofn = $ARGV[2];

######################################################################################################
# read codon table
######################################################################################################

my %codons;

print STDERR "reading table: $ifn_codon\n";
open(IN, $ifn_codon) || die $ifn_codon;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $codon = $f[$h{codon}];
    my $ka = $f[$h{ka}];
    my $ks = $f[$h{ks}];
    $codons{$codon} = {};
    $codons{$codon}->{ka} = $ka;
    $codons{$codon}->{ks} = $ks;
}
close(IN);

######################################################################################################
# go over genes
######################################################################################################

print STDERR "reading table: $ifn_genes\n";
open(IN, $ifn_genes) || die $ifn_genes;

print STDERR "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "gene\tka\tks\n";

my $gene = "";
my $seq = "";
my $count = 0;
while (my $line = <IN>) {
    chomp $line;
    if (substr($line,0,1) eq ">") {
	if ($gene ne "") {
	    my ($ka,$ks) = compute_ka_ks($seq);
	    print OUT $gene, "\t", $ka, "\t", $ks, "\n";
	    $count++;
	    if ($count % 100000 == 0) {
		print "gene: $count\n";
	    } 
	}
	$gene = substr($line,1);
	$seq = "";
    } else {
	$seq .= $line;
    }
}
if ($gene ne "") {
    my ($ka,$ks) = compute_ka_ks($seq);
    print OUT $gene, "\t", $ka, "\t", $ks, "\n";
}

close(OUT);
close(IN);

######################################################################################################
# Subroutines
######################################################################################################

sub compute_ka_ks
{
    my ($seq) = @_;
    my ($ka,$ks) = (0,0);
    my $n = floor(length($seq)/3);
    $n == length($seq)/3 or die "number of nucs must devide by 3";
    for (my $i=0; $i<$n; $i++) {
	my $codon = substr($seq,$i*3,3);
	defined($codons{$codon}) or die;
	$ka += $codons{$codon}->{ka};
	$ks += $codons{$codon}->{ks};
    }
    return ($ka,$ks);
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
