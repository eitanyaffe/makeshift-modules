#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <min fix count> <fixed threshold> <min poly count> <poly threshold> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $min_fix_count = $ARGV[1];
my $fix_t = $ARGV[2];
my $min_poly_count = $ARGV[3];
my $poly_t = $ARGV[4];
my $ofn = $ARGV[5];

#######################################################################################
# classify and output
#######################################################################################

print "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;

my $header = <IN>;
my %h = parse_header($header);

print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
chomp($header);
print OUT "contig\tcoord\tbase_nt\tset_nt\tbase_count\tbase_total\tset_count\tset_total\tbase_live\tset_live\tfix\n";

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig  = $f[$h{contig}];
    my $coord  = $f[$h{coord}];

    my %counts = ( "base" => {}, "set" => {});
    my %totals = ( "base" => 0, "set" => 0);
    foreach my $nt (("A", "C", "G", "T")) {
	$counts{base}->{$nt} = $f[$h{$nt."_base"}];
	$counts{set}->{$nt} = $f[$h{$nt."_set"}];
	$totals{base} += $counts{base}->{$nt};
	$totals{set} += $counts{set}->{$nt};
    }

    # get dominant alleles
    my %max_count = ( "base" => 0, "set" => 0);
    my %max_nt = ( "base" => "", "set" => "");
    foreach my $type (("base", "set")) {
	foreach my $nt (("A", "C", "G", "T")) {
	    if ($counts{$type}->{$nt} > $max_count{$type}) {
		$max_count{$type} = $counts{$type}->{$nt};
		$max_nt{$type} = $nt;
	    }
	}
    }
    my %freq = ( "base" => $totals{base} > 0 ? $max_count{base} / $totals{base} : 0, 
		 "set"  => $totals{set}  > 0 ? $max_count{set}  / $totals{set}  : 0);

    # classify poly
    my %is_poly = ( "base" => 0, "set" => 0);
    foreach my $type (("base", "set")) {
	$is_poly{$type} = ($totals{$type} >= $min_poly_count) && ($freq{$type} < ($poly_t));
    }

    # classify fix
    my $is_fix = (
	($totals{base} >= $min_fix_count && $totals{set} >= $min_fix_count) &&
	($max_nt{base} ne $max_nt{set}) &&
	($freq{base} >= $fix_t) && ($freq{set} >= $fix_t));

    if ($is_fix || $is_poly{base} || $is_poly{set}) {
	print OUT $contig, "\t", $coord, "\t";
	print OUT $max_nt{base}, "\t", $max_nt{set},"\t";
	print OUT $max_count{base}, "\t", $totals{base}, "\t";
	print OUT $max_count{set}, "\t", $totals{set}, "\t";
	print OUT $is_poly{base} ? "T" : "F", "\t", $is_poly{set} ? "T" : "F", "\t", $is_fix ? "T" : "F", "\n";
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
