#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <gene table> <geneset table> <set field> <ofn>\n";
	exit 1;
}

my $ifn_gene = $ARGV[0];
my $ifn_geneset = $ARGV[1];
my $field = $ARGV[2];
my $ofn = $ARGV[3];

###############################################################################################
# load genes
###############################################################################################

my %gene2contig;
my %contigs;

print "reading table: $ifn_gene\n";
open(IN, $ifn_gene) || die $ifn_gene;
my $header = <IN>;
my %h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    my $contig = $f[$h{contig}];
    my $start = $f[$h{start}];
    my $end = $f[$h{end}];

    $gene2contig{$gene} = $contig;

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{index2gene} = {};
	$contigs{$contig}->{genes} = {};
	$contigs{$contig}->{gene_count} = 0;
    }

    my $gene_index = ++$contigs{$contig}->{gene_count};

    $contigs{$contig}->{genes}->{$gene} = {};
    $contigs{$contig}->{genes}->{$gene}->{start} = $start;
    $contigs{$contig}->{genes}->{$gene}->{end} = $end;
    $contigs{$contig}->{genes}->{$gene}->{index} = $gene_index;

    $contigs{$contig}->{index2gene}->{$gene_index} = $gene;
}
close(IN);

###############################################################################################
# load genesets
###############################################################################################

our %sets;

print "reading table: $ifn_geneset\n";
open(IN, $ifn_geneset) || die $ifn_geneset;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    my $set = $f[$h{$field}];

    defined($gene2contig{$gene}) or die;
    my $contig = $gene2contig{$gene};

    defined($contigs{$contig}->{genes}->{$gene}) or die;
    my $gene_index = $contigs{$contig}->{genes}->{$gene}->{index};

    if (!defined($sets{$set})) {
	$sets{$set} = {};
    }
    if (!defined($sets{$set}->{$contig})) {
	$sets{$set}->{$contig} = {};
	$sets{$set}->{$contig}->{gene_index} = {};
	$sets{$set}->{$contig}->{segment} = {};
    }
    $sets{$set}->{$contig}->{gene_index}->{$gene_index} = 1;

}
close(IN);

###############################################################################################
# compute segments
###############################################################################################

our $segment_index = 0;

foreach my $set (keys %sets) {
    foreach my $contig (keys %{$sets{$set}}) {
	my @indices = sort {$a <=> $b} keys %{$sets{$set}->{$contig}->{gene_index}};
	# print "s=$set, c=$contig: ", join(",", @indices), "\n";

	my $prev_index = -1;
	my $first_index = -1;
	foreach my $index (@indices) {
	    if ($index-$prev_index > 1) {
		if ($first_index != -1) {
		    add_segment($set,$contig,$first_index,$prev_index);
		}
		$first_index = $index;
	    }
	    $prev_index = $index;
	}
	add_segment($set,$contig,$first_index,$prev_index);
    }
}

###############################################################################################
# output segments
###############################################################################################

print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "set\tcontig\tsegment\tstart\tend\tlength\tgene_count\n";

foreach my $set (keys %sets) {
    foreach my $contig (keys %{$sets{$set}}) {
	foreach my $segment (sort {$a <=> $b} keys %{$sets{$set}->{$contig}->{segment}}) {
	    my $start_index = $sets{$set}->{$contig}->{segment}->{$segment}->{start_index};
	    my $end_index = $sets{$set}->{$contig}->{segment}->{$segment}->{end_index};

	    # print "$contig, i:$segment, s:$start_index, e:$end_index\n";

	    defined($contigs{$contig}->{index2gene}->{$start_index}) or die;
	    defined($contigs{$contig}->{index2gene}->{$end_index}) or die;
	    my $start_gene = $contigs{$contig}->{index2gene}->{$start_index};
	    my $end_gene = $contigs{$contig}->{index2gene}->{$end_index};

	    my $start_coord = $contigs{$contig}->{genes}->{$start_gene}->{start};
	    my $end_coord = $contigs{$contig}->{genes}->{$end_gene}->{end};

	    my $length = $end_coord - $start_coord + 1;
	    my $gene_count = $end_index - $start_index + 1;
	    print OUT $set, "\t", $contig, "\t", $segment, "\t", $start_coord, "\t", $end_coord, "\t", $length, "\t", $gene_count, "\n";
	}
    }
}
close(OUT);

###############################################################################################
# utility functions
###############################################################################################

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

sub add_segment
{
    my ($set,$contig,$start_index,$end_index) = @_;
    $segment_index++;
    $sets{$set}->{$contig}->{segment}->{$segment_index} = {};
    $sets{$set}->{$contig}->{segment}->{$segment_index}->{start_index} = $start_index;
    $sets{$set}->{$contig}->{segment}->{$segment_index}->{end_index} = $end_index;
#    print "add: i=$segment_index, s=$start_index, e=$end_index\n";
}

