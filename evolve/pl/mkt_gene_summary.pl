#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;
use Switch;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <gene table> <gene nt> <nt table> <codon table> <ofn details> <ofn summary>\n";
	exit 1;
}

my $ifn_gene_table = $ARGV[0];
my $ifn_gene_nt = $ARGV[1];
my $ifn_nt = $ARGV[2];
my $ifn_codon = $ARGV[3];
my $ofn_details = $ARGV[4];
my $ofn_summary = $ARGV[5];

######################################################################################################
# read codon table
######################################################################################################

my %codons;
print STDERR "reading codon table: $ifn_codon\n";
open(IN, $ifn_codon) || die $ifn_codon;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $codon = $f[$h{codon}];
    my $aa = $f[$h{aa}];
    my $extra = $f[$h{extra}];
    if ($extra eq '-' || $aa eq '*') {
	$codons{$codon} = $aa;
    } else {
	$codons{$codon} = $aa.'-'.$extra;
    }
}
close(IN);

######################################################################################################
# read gene table
######################################################################################################

my %genes;
my @gene_arr;

print STDERR "reading gene table: $ifn_gene_table\n";
open(IN, $ifn_gene_table) || die $ifn_gene_table;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    $genes{$gene} = {};
    $genes{$gene}->{contig} = $f[$h{contig}];
    $genes{$gene}->{start} = $f[$h{start}];
    $genes{$gene}->{end} = $f[$h{end}];
    $genes{$gene}->{strand} = $f[$h{strand}];

    # for summary
    $genes{$gene}->{class} = {};
    $genes{$gene}->{class}->{syn} = 0;
    $genes{$gene}->{class}->{non_syn} = 0;
    $genes{$gene}->{class}->{id} = 0;
    $genes{$gene}->{count} = 0;
    push(@gene_arr, $gene);
}
close(IN);

######################################################################################################
# read gene seq
######################################################################################################

print STDERR "reading gene seq: $ifn_gene_nt\n";
open(IN, $ifn_gene_nt) || die $ifn_gene_nt;

my $gene = "";
my $seq = "";
while (my $line = <IN>) {
    chomp $line;
    if (substr($line,0,1) eq ">") {
	if ($gene ne "") {
	    defined($genes{$gene}) or die;
	    $genes{$gene}->{seq} = $seq;
	}
	$gene = substr($line,1);
	$seq = "";
    } else {
	$seq .= $line;
    }
}
if ($gene ne "") {
    defined($genes{$gene}) or die;
    $genes{$gene}->{seq} = $seq;
}
close(IN);

######################################################################################################
# go over nt table
######################################################################################################

print STDERR "reading nt table: $ifn_nt\n";
open(IN, $ifn_nt) || die $ifn_nt;
$header = <IN>;
%h = parse_header($header);

print STDERR "writing detail table: $ofn_details\n";
open(OUT, ">", $ofn_details) || die $ofn_details;
print OUT "gene\tstrand\tnt_coord\taa_coord\tcodon_ref\tcodon_found\taa_ref\taa_found\tclass\n";

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $base_nt = $f[$h{nt}];
    defined($genes{$gene}) or die;
    $genes{$gene}->{contig} eq $contig or die;
    defined($genes{$gene}->{seq}) or die;
    my $seq = $genes{$gene}->{seq};

    # !!! go back into the poly pipeline and figure out why the sequence column gets a value of "TRUE"
    next if ($base_nt eq "TRUE");

    my $plus_strand = $genes{$gene}->{strand} eq '+';
    my $gene_index = $plus_strand ? ($coord - $genes{$gene}->{start}) : ($genes{$gene}->{end} - $coord);
    my $nt = $plus_strand ? $base_nt : comp($base_nt);

    my $codon_index = floor($gene_index / 3);
    my $nt_index = $gene_index - $codon_index*3;

    my $ref_codon = substr($seq,3*$codon_index,3);
    my $codon = $ref_codon;
    substr($codon,$nt_index,1) = $nt;

    defined($codons{$ref_codon}) or die $ref_codon;
    defined($codons{$codon}) or die $base_nt;
    my $ref_aa = $codons{$ref_codon};
    my $aa = $codons{$codon};

    my $class = ($ref_codon eq $codon) ? "id" : (($ref_aa eq $aa) ? "syn" : "non_syn");

    print OUT $gene, "\t", $genes{$gene}->{strand}, "\t", $gene_index+1, "\t", $codon_index+1, "\t";
    print OUT $ref_codon, "\t", $codon, "\t", $ref_aa, "\t", $aa, "\t", $class, "\n";

    defined($genes{$gene}->{class}->{$class}) or die;
    $genes{$gene}->{class}->{$class}++;
    $genes{$gene}->{count}++;

}
close(IN);
close(OUT);

######################################################################################################
# gene summary
######################################################################################################

print STDERR "writing summary table: $ofn_summary\n";
open(OUT, ">", $ofn_summary) || die $ofn_summary;
print OUT "gene\tid\tsyn\tnon_syn\n";
foreach my $gene (@gene_arr) {
    defined($genes{$gene}) or die;
    next if ($genes{$gene}->{count} == 0);
    print OUT $gene, "\t", $genes{$gene}->{class}->{id}, "\t", $genes{$gene}->{class}->{syn}, "\t", $genes{$gene}->{class}->{non_syn}, "\n";
}
close(OUT);

######################################################################################################
# Subroutines
######################################################################################################

sub comp
{
    switch ($_[0]) {
	case 'A' { return 'T' }
	case 'C' { return 'G' }
	case 'G' { return 'C' }
	case 'T' { return 'A' }
    }
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
