#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn genes> <ifn genes uniref> <ifn sites> <ofn>\n";
	exit 1;
}

my $ifn_genes = $ARGV[0];
my $ifn_uniref = $ARGV[1];
my $ifn_sites = $ARGV[2];
my $ofn = $ARGV[3];

###################################################################################################################
# read genes
###################################################################################################################

my %contigs;
my %genes;

print "reading table: $ifn_genes\n";
open(IN, $ifn_genes) || die $ifn_genes;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $gene = $f[$h{gene}];
    my $start = $f[$h{start}];
    my $end = $f[$h{end}];

    $genes{$gene} = {};
    $genes{$gene}->{start} = $start;
    $genes{$gene}->{end} = $end;
    $genes{$gene}->{count} = 0;

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{genes} = {};
	$contigs{$contig}->{coords} = {};
    }
    $contigs{$contig}->{genes}->{$gene} = {};
    $contigs{$contig}->{coords}->{$start} = $gene;
}
close(IN);

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
# read uniref
###################################################################################################################

my %uniref;

print "reading table: $ifn_uniref\n";
open(IN, $ifn_uniref) || die $ifn_uniref;
$header = <IN>;
my $uniref_header = $header;
chomp($uniref_header);
%h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    $uniref{$gene} = $line;
}
close(IN);

###################################################################################################################
# site table
###################################################################################################################

print "reading table: $ifn_sites\n";
open(IN, $ifn_sites) || die $ifn_sites;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $bin = $f[$h{bin}];

    next if (!defined($contigs{$contig}));
    my $index = binary_search($contigs{$contig}->{sorted_coords}, $coord, 0);
    next if ($index == -1);
    my $gene_coord = $contigs{$contig}->{sorted_coords}[$index];
    defined($contigs{$contig}->{coords}->{$gene_coord}) or die;
    my $gene = $contigs{$contig}->{coords}->{$gene_coord};

    defined($genes{$gene}) or die;
    next if ($coord < $genes{$gene}->{start} || $coord > $genes{$gene}->{end});
    next if (!defined($uniref{$gene}));
    $genes{$gene}->{count} += 1;
    $genes{$gene}->{bin} = $bin;
    $genes{$gene}->{contig} = $contig;
}
close(IN);

print "writing output: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "bin\tcontig\tcount\t", $uniref_header, "\n";
foreach my $gene (keys %genes) {
    next if ($genes{$gene}->{count} == 0);
    defined($uniref{$gene}) or die;
    print OUT $genes{$gene}->{bin}, "\t", $genes{$gene}->{contig}, "\t", $genes{$gene}->{count}, "\t", $uniref{$gene}, "\n";

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
