#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
    print STDERR "usage: $0 <fend table> <contig cluster table> <ofn>\n";
    exit 1;
}

my $ifn = $ARGV[0];
my $cluster_table = $ARGV[1];
my $ofn = $ARGV[2];

#######################################################################################
# read cluster table
#######################################################################################

my %contigs;

print STDERR "reading cluster table: $cluster_table\n";
open(IN, $cluster_table) || die $cluster_table;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $cluster = $f[$h{cluster}];
    my $start = $f[$h{start}];
    my $end = $f[$h{end}];

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{coords} = {};
    }
    $contigs{$contig}->{coords}->{$start} = {};
    $contigs{$contig}->{coords}->{$start}->{start} = $start;
    $contigs{$contig}->{coords}->{$start}->{end} = $end;
    $contigs{$contig}->{coords}->{$start}->{cluster} = $cluster;
}
close(IN);

foreach my $contig (keys %contigs) {
    my @sorted = sort {$a <=> $b} keys %{$contigs{$contig}->{coords}};
    $contigs{$contig}->{sorted_coords} = \@sorted;
}

#######################################################################################
# traverse fends
#######################################################################################

print STDERR "traversing fends file: $ifn\n";
open(IN, $ifn) || die $ifn;
$header = <IN>;
chomp($header);
%h = parse_header($header);

print STDERR "generating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

print OUT $header, "\tcluster\n";

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    next if (!defined($contigs{$contig}));

    my $index = binary_search($contigs{$contig}->{sorted_coords}, $coord, "-");
    next if ($index == -1);

    # segment start
    my $start = $contigs{$contig}->{sorted_coords}[$index];

    defined ($contigs{$contig}->{coords}->{$start}) or die;
    my $end = $contigs{$contig}->{coords}->{$start}->{end};

    # skip if not inside bin
    next if (!($start <= $coord && $coord <= $end));

    # get cluster
    my $cluster = $contigs{$contig}->{coords}->{$start}->{cluster};
    print OUT $line, "\t", $cluster, "\n";
}
close(IN);
close(OUT);

#######################################################################################
# utils
#######################################################################################

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
