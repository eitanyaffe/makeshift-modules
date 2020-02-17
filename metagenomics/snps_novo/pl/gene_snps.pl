#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn gene segments> <ifn gene base cov> <ifn gene cov> <ifn snps table> <ofn summary> <ofn details>\n";
	exit 1;
}

my $ifn_genes = $ARGV[0];
my $ifn_base_cov = $ARGV[1];
my $ifn_cov = $ARGV[2];
my $ifn_snps = $ARGV[3];
my $ofn_summary = $ARGV[4];
my $ofn_details = $ARGV[5];

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
    $genes{$gene}->{length} = $end-$start+1;
    $genes{$gene}->{base_live_count} = 0;
    $genes{$gene}->{set_live_count} = 0;
    $genes{$gene}->{fix_count} = 0;

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

foreach my $type (("base", "set")) {
    my $ifn = $type eq "base" ? $ifn_base_cov : $ifn_cov;
    print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;
    $header = <IN>;
    %h = parse_header($header);
    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $gene = $f[$h{gene}];
	my $cov = $f[$h{coverage}];
	defined($genes{$gene}) or die;
	$genes{$gene}->{$type} = $cov;
    }
    close(IN);
}

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

print "reading table: $ifn_snps\n";
open(IN, $ifn_snps) || die $ifn_snps;
$header = <IN>;
%h = parse_header($header);

print "writing detailed table: $ofn_details\n";
open(OUT, ">", $ofn_details) || die $ofn_details;
chomp($header);
print OUT $header, "\tgene\n";

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $base_live = $f[$h{base_live}] eq "T" ? 1 : 0;
    my $set_live = $f[$h{set_live}] eq "T" ? 1 : 0;
    my $fix = $f[$h{fix}] eq "T" ? 1 : 0;
    next if (!defined($contigs{$contig}));
    my $index = binary_search($contigs{$contig}->{sorted_coords}, $coord, 0);
    next if ($index == -1);
    my $gene_coord = $contigs{$contig}->{sorted_coords}[$index];
    defined($contigs{$contig}->{coords}->{$gene_coord}) or die;
    my $gene = $contigs{$contig}->{coords}->{$gene_coord};
    defined($genes{$gene}) or die;
    next if ($coord < $genes{$gene}->{start} || $coord > $genes{$gene}->{end});

    $genes{$gene}->{base_live_count} += $base_live;
    $genes{$gene}->{set_live_count} += $set_live;
    $genes{$gene}->{fix_count} += $fix;

    print OUT $line, "\t", $gene, "\n";

}
close(IN);
close(OUT);

#######################################################################################
# classify and output
#######################################################################################

print "writing table: $ofn_summary\n";
open(OUT, ">", $ofn_summary) || die $ofn_summary;

print OUT "contig\tgene\tlength\tbase_cov\tset_cov\tlive_base\tlive_set\tfix\n";
foreach my $contig (keys %contigs) {
    foreach my $gene (keys %{$contigs{$contig}->{genes}}) {
	defined($genes{$gene}->{base}) && defined($genes{$gene}->{set}) or die;
	print OUT $contig, "\t", $gene, "\t", $genes{$gene}->{length}, "\t";
	print OUT $genes{$gene}->{base}, "\t", $genes{$gene}->{set}, "\t";
	print OUT $genes{$gene}->{base_live_count}, "\t", $genes{$gene}->{set_live_count}, "\t", $genes{$gene}->{fix_count}, "\n";
    } 
}
close(OUT);

#######################################################################################
# utils
#######################################################################################

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
