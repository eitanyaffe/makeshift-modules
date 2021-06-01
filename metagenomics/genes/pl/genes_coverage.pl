#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <gene table> <reads ifn1> <reads ifn2> <remove clipped T|F> <min score> <max edit distance> < min match length> <ofn table> <ofn stats>\n";
	exit 1;
}

my $genes_ifn = $ARGV[0];
my $reads_ifn1 = $ARGV[1];
my $reads_ifn2 = $ARGV[2];
my $remove_clipped =$ARGV[3]  eq "T";
my $min_score = $ARGV[4];
my $max_dist = $ARGV[5];
my $min_match = $ARGV[6];
my $ofn_table = $ARGV[7];
my $ofn_stats = $ARGV[8];

###############################################################################################
# read bins
###############################################################################################

my %genes;
my %contigs;

print "reading gene table: $genes_ifn\n";
open(IN, $genes_ifn) || die $genes_ifn;
my $header = <IN>;
my %h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    my $contig = $f[$h{contig}];
    my $start = $f[$h{start}];
    my $end = $f[$h{end}];

    # gene hash
    $genes{$gene} = {};
    $genes{$gene}->{contig} = $contig;
    $genes{$gene}->{start} = $start;
    $genes{$gene}->{end} = $end;
    $genes{$gene}->{length} = $end-$start+1;
    $genes{$gene}->{count} = 0;

    # contig hash
    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{coord2gene} = {};
    }
    $contigs{$contig}->{coord2gene}->{$start} = $gene;
}

foreach my $contig (keys %contigs) {
    my @sorted = sort {$a <=> $b} keys %{$contigs{$contig}->{coord2gene}};
    $contigs{$contig}->{sorted_coords} = \@sorted;
}

###############################################################################################
# traverse all reads
###############################################################################################

my $total_count = 0;
my $filtered_count = 0;
my $gene_count = 0;

foreach my $ifn ($reads_ifn1, $reads_ifn2) {
    print "traversing file: $ifn\n";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    my %h = parse_header($header);
    while (my $line = <IN>) {
	chomp $line;
	my @f = split("\t", $line);
	my $contig = $f[$h{contig}];
	my $coord = $f[$h{coord}];
	my $back_coord = $f[$h{back_coord}];
	my $strand = $f[$h{strand}];
	my $min_coord = $strand == 1 ? $back_coord : $coord;
	
	# for filtering
	if (($f[$h{edit_dist}] > $max_dist) || ($f[$h{score}] < $min_score) || ($f[$h{match_length}] < $min_match) ||
	    ($remove_clipped && ($f[$h{cigar}] ne $f[$h{match_length}]."M"))) {
	    $filtered_count++;
	    next;
	}
	
	$total_count++;
	
	# skip if no contig found
	next if (!defined($contigs{$contig}));
	
	# find nearest gene
	my $gene_index = binary_search($contigs{$contig}->{sorted_coords}, $min_coord, "-");
	my $gene_coord = ($gene_index != -1) ? $contigs{$contig}->{sorted_coords}[$gene_index] : -1;
	
	# skip if no gene found
	next if ($gene_coord == -1);
	
	defined ($contigs{$contig}->{coord2gene}->{$gene_coord}) or die;
	my $gene = $contigs{$contig}->{coord2gene}->{$gene_coord};
	my $start = $genes{$gene}->{start};
	my $end = $genes{$gene}->{end};
	
	# skip if not inside gene
	next if (!($start <= $coord && $coord <= $end));
	
	$genes{$gene}->{count} += 1;
	$gene_count++;
    }
    close(IN);
}

###############################################################################################
# traverse all reads
###############################################################################################

print "generating table: $ofn_table\n";
open(OUT, ">", $ofn_table) || die $ofn_table;
print OUT "gene\tcontig\tstart\tend\tlength\tcount\tRPK\n";
foreach my $gene (keys %genes) {
    my $density = 1000 * $genes{$gene}->{count} / $genes{$gene}->{length};
    print OUT $gene, "\t", $genes{$gene}->{contig}, "\t", $genes{$gene}->{start}, "\t", $genes{$gene}->{end}, "\t", $genes{$gene}->{length}, "\t";
    print OUT $genes{$gene}->{count}, "\t", $density, "\n";
}
close(OUT);

print "generating table: $ofn_stats\n";
open(OUT, ">", $ofn_stats) || die $ofn_stats;
print OUT "total_count\tfilter_count\tgene_count\n";
print OUT "$total_count\t$filtered_count\t$gene_count\n";
close(OUT);

######################################################################################################
# Subroutines
######################################################################################################

# returns first element above/below value in sorted array
sub binary_search
{
    my $arr = shift;
    my $value = shift;
    my $above = shift;

    my $left = 0;
    my $right = $#$arr;

    while ($left <= $right) {
	my $mid = ($right + $left) >> 1;
	my $c = $arr->[$mid] <=> $value;
	return $mid if ($c == 0);
	if ($c > 0) {
	    $right = $mid - 1;
	} else {
	    $left  = $mid + 1;
	}
    }
    $left = -1 if ($left > $#$arr);
    $right = -1 if ($right < 0);
    return (($above eq "+") ? $left : $right);
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
