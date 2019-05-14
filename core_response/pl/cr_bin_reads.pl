#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <bin table> <input dir> <ofn table> <ofn stats>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $idir = $ARGV[1];
my $ofn_table = $ARGV[2];
my $ofn_stats = $ARGV[3];

###############################################################################################
# read bins
###############################################################################################

my %contigs;

print "reading bin table: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);

chomp $header;
my @fields = split("\t", $header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $start = $f[$h{start}];

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{coord2bin} = {};
    }

    # add bin details
    $contigs{$contig}->{coord2bin}->{$start} = {};
    $contigs{$contig}->{coord2bin}->{$start}->{count} = 0;
    foreach my $field (@fields) {
	$contigs{$contig}->{coord2bin}->{$start}->{$field} = $f[$h{$field}];
    }
}

foreach my $contig (keys %contigs) {
    my @sorted = sort {$a <=> $b} keys %{$contigs{$contig}->{coord2bin}};
    $contigs{$contig}->{sorted_coords} = \@sorted;
}

###############################################################################################
# traverse all reads
###############################################################################################

print "input dir: $idir\n";
my @ifns = <$idir/*>;
print "number of input files: ", scalar(@ifns), "\n";
scalar(@ifns) > 0 or die;

my $total_count = 0;
my $binned_count = 0;

foreach my $ifn (@ifns) {
    next if (basename($ifn) eq "files");
    print ".";
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

	$total_count++;

	# skip if no contig found
	next if (!defined($contigs{$contig}));

	# find nearest bin
	my $bin_index = binary_search($contigs{$contig}->{sorted_coords}, $min_coord, "-");
	my $bin_coord = ($bin_index != -1) ? $contigs{$contig}->{sorted_coords}[$bin_index] : -1;

	# skip if no bin found
	next if ($bin_coord == -1);

	defined ($contigs{$contig}->{coord2bin}->{$bin_coord}) or die;
	my $start = $bin_coord;
	my $end = $contigs{$contig}->{coord2bin}->{$start}->{end};

	# skip if not inside bin
	next if (!($start <= $coord && $coord <= $end));

	$contigs{$contig}->{coord2bin}->{$bin_coord}->{count} += 1;

	$binned_count++;
    }
    close(IN);
}
print "\n";

###############################################################################################
# traverse all reads
###############################################################################################

print "generating table: $ofn_table\n";
open(OUT, ">", $ofn_table) || die $ofn_table;
foreach my $field (@fields) {
    print OUT $field, "\t";
}
print OUT "count\n";

foreach my $contig (keys %contigs) {
    foreach my $coord (keys %{$contigs{$contig}->{coord2bin}}) {
	foreach my $field (@fields) {
	    print OUT $contigs{$contig}->{coord2bin}->{$coord}->{$field}, "\t";
	}
	print OUT $contigs{$contig}->{coord2bin}->{$coord}->{count}, "\n";
    }
}
close(OUT);

print "generating table: $ofn_stats\n";
open(OUT, ">", $ofn_stats) || die $ofn_stats;
print OUT "total_count\tbinned_count\n";
print OUT "$total_count\t$binned_count\n";
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
