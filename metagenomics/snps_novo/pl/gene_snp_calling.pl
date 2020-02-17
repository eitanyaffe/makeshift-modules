#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn genes> <ifn base> <ifn set> <min count> <live threshold> <fixed threshold> <ofn>\n";
	exit 1;
}

my $ifn_genes = $ARGV[0];
my $ifn_cov = $ARGV[1];
my $ifn_base = $ARGV[2];
my $ifn_set = $ARGV[3];
my $min_count = $ARGV[4];
my $live_t = $ARGV[5];
my $fix_t = $ARGV[6];
my $ofn = $ARGV[7];

###################################################################################################################
# gene segments
###################################################################################################################

my %genes;
my %contigs;

print "reading table: $ifn_genes\n";
open(IN, $ifn_genes) || die $ifn_genes;
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
    $genes{$gene}->{coords} = {};

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{genes} = {};
	$contigs{$contig}->{coords} = {};
    }
    $contigs{$contig}->{genes}->{$gene} = 1;
    $contigs{$contig}->{coords}->{$start} = $gene;
}
close(IN);

###################################################################################################################
# add coverage
###################################################################################################################

foreach my $contig (keys %contigs) {

    my @coverage_vector = (0) x $contigs{$contig}->{length};

    # 1. read contig coverage into single vector
    foreach my $id (@ids) {
	my $ifn = sprintf("%s/%s/vari/output_full/%s.cov", $idir, $id, $contig);
	# my $ifn = sprintf("%s/%s", $idir, $id);
	open(IN, $ifn) || die $ifn;
	my $index = 0;
	while (my $line = <IN>) {
	    $coverage_vector[$index++] += $line;
	}
	close(IN);
    }
    $contigs{$contig}->{coverage} = \@coverage_vector;
}

print "number of genes: ", scalar keys %genes, "\n";
print "number of contigs: ", scalar keys %contigs, "\n";

###################################################################################################################
# sort contig coordinates
###################################################################################################################

# compute sorted coords per contig
foreach my $contig (keys %contigs)
{
    my @sorted = sort {$a <=> $b} keys %{$contigs{$contig}->{coords}};
    $contigs{$contig}->{sorted_coords} = \@sorted;
}

###################################################################################################################
# load tables
###################################################################################################################

foreach my $type (("base", "set")) {
    my $ifn = $type eq "base" ? $ifn_base : $ifn_set;
    print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;
    $header = <IN>;
    %h = parse_header($header);
    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $contig = $f[$h{contig}];
	my $coord = $f[$h{coord}];

	my $index = binary_search($contigs{$contig}->{sorted_coords}, $coord, 0);
	print "coord=$coord, index=$index\n";
	next if ($index == -1);
	my $gene_coord = $contigs{$contig}->{sorted_coords}[$index];
	defined($contigs{$contig}->{coords}->{$gene_coord}) or die;
	my $gene = $contigs{$contig}->{coords}->{$gene_coord};
	defined($genes{$gene}) or die;

	$genes{$gene}->{coords}->{$coord} = {} if (!defined($genes{$gene}->{coords}->{$coord}));

	$genes{$gene}->{coords}->{$coord}->{$type} = {};
	$genes{$gene}->{coords}->{$coord}->{$type}->{total} = 0;
	foreach my $nt (("A", "C", "G", "T")) {
	    $genes{$gene}->{coords}->{$coord}->{$type}->{$nt} = $f[$h{$nt}];
	    $genes{$gene}->{coords}->{$coord}->{$type}->{total} += $f[$h{$nt}];
	}
    }
}

#######################################################################################
# classify and output
#######################################################################################

print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

print OUT "gene\tcoord\tlive_base\tlive_set\tfix\n";
# compute sorted coords per contig
foreach my $gene (keys %genes)
{
    print "gene: $gene\n";
    foreach my $coord (sort {$a <=> $b} keys %{$genes{$gene}->{coords}}) {
	print " coord: $coord\n";
	# classify live
	my ($base_live, $set_live) = (0,0);
	foreach my $type (("base", "set")) {
	    my $live = 0;
	    my $total = $genes{$gene}->{coords}->{$coord}->{$type}->{total};
	    foreach my $nt (("A", "C", "G", "T")) {
		my $count = $genes{$gene}->{coords}->{$coord}->{$type}->{$nt};
		next if ($count < $min_count);
		my $freq = $count / $total;
		$live |= ($freq >= $live_t) & ($freq <= (1-$live_t));
	    }
 	    print " $type : live=", $live, "\n";
	    (($type eq "base") ? $base_live : $set_live) = $live;
	}

	# classify fix
	my $fix = 0;
	my $base_total = $genes{$gene}->{coords}->{$coord}->{base}->{total};
	my $set_total = $genes{$gene}->{coords}->{$coord}->{set}->{total};
	if ($base_total >= $min_count && $set_total >= $min_count) {
	    foreach my $nt (("A", "C", "G", "T")) {
		my $base_f = $genes{$gene}->{coords}->{$coord}->{base}->{$nt} / $base_total;
		my $set_f = $genes{$gene}->{coords}->{$coord}->{set}->{$nt} / $set_total;
		$fix |= (($base_f < $fix_t) && ($set_f > (1-$fix_t))) || (($set_f < $fix_t) && ($base_f > (1-$fix_t)))
	    }
 	    print " fix=", $fix, "\n";
	}

	next if (!($base_live || $set_live || $fix));
	print OUT $gene, "\t", $coord, "\t", $base_live, "\t", $set_live, "\t", $fix, "\n";
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
    return ($above ? $left : $right);
}
