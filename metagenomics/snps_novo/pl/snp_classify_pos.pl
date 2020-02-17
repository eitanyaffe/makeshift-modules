#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <prefix> <min total count> <fixed threshold> <poly threshold> <ofn>\n";
	exit 1;
}

my $prefix = $ARGV[0];
my $min_total_count = $ARGV[1];
my $fix_t = $ARGV[2];
my $poly_t = $ARGV[3];
my $ofn = $ARGV[4];

#######################################################################################
# read matrix into memory
#######################################################################################

my %contigs;

my $ids_set = 0;
my @ids;

my @exts = ("A", "C", "G", "T", "total");
for (my $i=0; $i<5; $i++) {
    my $ifn = $prefix.".".$exts[$i];
    print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;

    my $header = <IN>;
    my %h = parse_header($header);

    if (!$ids_set) {
	@ids = keys(%h);
	@ids = grep {!/coord/} @ids;
	@ids = grep {!/contig/} @ids;
	$ids_set = 1;
    }

    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $contig  = $f[$h{contig}];
	my $coord  = $f[$h{coord}];

	# last if ($contig ne "k147_121517:s1");

	$contigs{$contig} = {} if (!defined($contigs{$contig}));
	$contigs{$contig}->{$coord} = {} if (!defined($contigs{$contig}->{$coord}));

	foreach my $id (@ids) {
	    my $count = $f[$h{$id}];
	    if (!defined($contigs{$contig}->{$coord}->{$id})) {
		$contigs{$contig}->{$coord}->{$id} = {};
		$contigs{$contig}->{$coord}->{$id}->{nts} = [0,0,0,0];
		$contigs{$contig}->{$coord}->{$id}->{total} = 0;
	    }
	    if ($i < 4) {
		$contigs{$contig}->{$coord}->{$id}->{nts}[$i] = $count;
	    } else {
		$contigs{$contig}->{$coord}->{$id}->{total} = $count;
	    }
	}
    }
    close(IN);
}

#######################################################################################
# classify each position
#######################################################################################

print "writing table: $ofn\n";
open(OUT, ">", $ofn);
print OUT "contig\tcoord\tsegrating_count\tfixed_count\n";

foreach my $contig (keys %contigs) {
    foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}}) {

	my $segrating_count = 0;
	my %fixed_nts;
	foreach my $id (@ids) {
	    my $total = $contigs{$contig}->{$coord}->{$id}->{total};
	    next if ($total < $min_total_count);

	    # find major nt in lib
	    my $max_nt_index = 0;
	    my $max_nt_count = 0;
	    for (my $i=0; $i<4; $i++) {
		my $count = $contigs{$contig}->{$coord}->{$id}->{nts}[$i];
		if ($count > $max_nt_count) {
		    $max_nt_index = $i;
		    $max_nt_count = $count;
		}
	    }
	    my $major_freq = $max_nt_count / $total;

	    # check if fixed
	    $fixed_nts{$max_nt_index} = 1 if ($major_freq >= $fix_t);
	    $segrating_count++ if ($major_freq <= $poly_t);
	}
	my $fixed_count = scalar(keys(%fixed_nts));
	next if (($fixed_count == 0) && ($segrating_count == 0));
	print OUT $contig, "\t", $coord, "\t", $segrating_count, "\t", $fixed_count, "\n";
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
