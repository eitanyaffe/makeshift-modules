#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <segment table> <site table> <ofn>\n";
	exit 1;
}

my $ifn_segments = $ARGV[0];
my $ifn_sites = $ARGV[1];
my $ofn = $ARGV[2];

###################################################################################################################
# load segments table
###################################################################################################################

my %contigs;

print "reading segment table: $ifn_segments\n";
open(IN, $ifn_segments) || die $ifn_segments;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $start = $f[$h{start}];
    my $end = $f[$h{end}];
    my $bin = $f[$h{bin}];

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{coords} = {};
    }
    $contigs{$contig}->{coords}->{$start} = {};
    $contigs{$contig}->{coords}->{$start}->{end} = $end;
    $contigs{$contig}->{coords}->{$start}->{bin} = $bin;
}
close(IN);

# compute sorted coords per contig
foreach my $contig (keys %contigs)
{
    my @sorted = sort {$a <=> $b} keys %{$contigs{$contig}->{coords}};
    $contigs{$contig}->{sorted_coords} = \@sorted;
}

###################################################################################################################
# traverse site table
###################################################################################################################

print "traversing sites table: $ifn_sites\n";
open(IN, $ifn_sites) || die $ifn_sites;
$header = <IN>;
%h = parse_header($header);

chomp($header);
print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "bin\t$header\n";

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    next if (!defined($contigs{$contig}));

    my $index = binary_search($contigs{$contig}->{sorted_coords}, $coord, "-");
    next if ($index == -1);

    my $segment_start = $contigs{$contig}->{sorted_coords}[$index];
    defined($contigs{$contig}->{coords}->{$segment_start}) or die;

    my $segment_end = $contigs{$contig}->{coords}->{$segment_start}->{end};
    my $bin = $contigs{$contig}->{coords}->{$segment_start}->{bin};

    # out of range of segment
    next if ($coord < $segment_start || $coord >= $segment_end);

    print OUT $bin, "\t", $line, "\n";
}

close(IN);
close(OUT);

###################################################################################################################
# utils
###################################################################################################################

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
    return (($above eq "+") ? $left : $right);
}
