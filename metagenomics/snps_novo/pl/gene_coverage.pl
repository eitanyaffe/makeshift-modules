#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <idir> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $idir = $ARGV[1];
my $ofn = $ARGV[2];

###################################################################################################################
# gene segments
###################################################################################################################

my %genes;
my %contigs;

print "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $gene = $f[$h{gene}];
    my $start = $f[$h{"trim.start"}];
    my $end = $f[$h{"trim.end"}];
    my $contig_length = $f[$h{"contig.length"}];
    die if (!($start <= $end));

    $genes{$gene} = {};
    $genes{$gene}->{start} = $start;
    $genes{$gene}->{end} = $end;


    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{genes} = {};
	$contigs{$contig}->{length} = 0;
    }

    $contigs{$contig}->{genes}->{$gene} = 1;
    $contigs{$contig}->{length} = $contig_length if ($contigs{$contig}->{length} == 0);
}
close(IN);

###################################################################################################################
# go over contigs
###################################################################################################################

print "number of genes: ", scalar keys %genes, "\n";
print "number of contigs: ", scalar keys %contigs, "\n";

my $count = 0;
print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "gene\tcontig\tstart\tend\tcoverage\n";
foreach my $contig (keys %contigs) {

    print "progress: ",$count-1, " contigs\n" if ($count++ % 10000 == 0);

    my @coverage_vector = (0) x $contigs{$contig}->{length};

    # 1. read contig coverage into single vector
    my $ifn_cov = sprintf("%s/%s", $idir, $contig);
    open(IN, $ifn_cov) || die $ifn_cov;
    my $index = 0;
    while (my $line = <IN>) {
	$coverage_vector[$index++] += $line;
    }
    close(IN);

    # 2. compute median coverage per gene
    foreach my $gene (keys %{$contigs{$contig}->{genes}}) {
	my $start = $genes{$gene}->{start};
	my $end = $genes{$gene}->{end};
	my $gene_med = median(@coverage_vector[($start-1) .. ($end-1)]);
	print OUT $gene, "\t", $contig, "\t", $start, "\t", $end, "\t", $gene_med, "\n";
    }
}
close(OUT);

#######################################################################################
# utils
#######################################################################################

sub median
{
    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;
    if($len%2) #odd?
    {
        return $vals[int($len/2)];
    }
    else #even
    {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}

sub apprx_lines
{
	my ($fn) = @_;
	my $tmp = "/tmp/".$$."_apprx_lines.tmp";
	system("head -n 100000 $fn > $tmp");
	my $size_head = -s $tmp;
	my $size_all = -s $fn;
	return (int($size_all/$size_head*100000));
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
