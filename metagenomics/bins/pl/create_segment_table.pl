#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
        print "usage: $0 <fragment table> <fragment bin table> <ofn segments>\n";
        exit 1;
}

my $ifn_frag = $ARGV[0];
my $ifn_bins = $ARGV[1];
my $ofn = $ARGV[2];

####################################################################################
# load fragments
####################################################################################


my %contigs;
my %fragment2contig;

print "reading fragment table: $ifn_frag\n";
open(IN, $ifn_frag) or die $ifn_frag;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $index = $f[$h{frag_index}];
    my $fragment = $f[$h{fragment_id}];
    my $start = $f[$h{start}];
    my $end = $f[$h{end}];

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{index2bin} = {};
	$contigs{$contig}->{index2fragment} = {};
	$contigs{$contig}->{fragments} = {};
    }
    $contigs{$contig}->{fragments}->{$fragment} = {};
    $contigs{$contig}->{fragments}->{$fragment}->{index} = $index;
    $contigs{$contig}->{fragments}->{$fragment}->{start} = $start;
    $contigs{$contig}->{fragments}->{$fragment}->{end} = $end;

    $contigs{$contig}->{index2fragment}->{$index} = $fragment;
    $contigs{$contig}->{index2bin}->{$index} = 0;

    $fragment2contig{$fragment} = $contig;
}
close(IN);

####################################################################################
# load bins
####################################################################################

print "reading fragment-bin table: $ifn_bins\n";
open(IN, $ifn_bins) or die $ifn_bins;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $fragment = $f[$h{contig}];
    my $bin = $f[$h{bin}];

    defined($fragment2contig{$fragment}) or die $fragment;
    my $contig = $fragment2contig{$fragment};

    defined($contigs{$contig}) or die;
    defined($contigs{$contig}->{fragments}->{$fragment}) or die;

    my $index = $contigs{$contig}->{fragments}->{$fragment}->{index};
    $contigs{$contig}->{index2bin}->{$index} = $bin;

}
close(IN);

####################################################################################
# output consecutive segments
####################################################################################

print "writing segment ofn: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "segment\tbin\tcontig\tstart_coord\tend_coord\tstart_fragment_index\tend_fragment_index\n";
foreach my $contig (keys %contigs) {
    my $segment_index = 1;
    my $prev_bin = -1;
    my $start_index = 1;
    my $last_index = -1;
    foreach my $index (sort {$a <=> $b} keys %{$contigs{$contig}->{index2bin}}) {
	my $bin = $contigs{$contig}->{index2bin}->{$index};
	# print "index: $index, bin: $bin\n";
	if (($bin != $prev_bin || $prev_bin == 0) && $index > 1) {
	    output_segment($contig, $segment_index, $prev_bin, $start_index, $index-1);
	    $segment_index++;
	    $start_index = $index;
	}
	$prev_bin = $bin;
	$last_index = $index;
    }
    output_segment($contig, $segment_index, $prev_bin, $start_index, $last_index);
}
close(OUT);

#######################################################################################
# utils
#######################################################################################

sub output_segment
{
    my ($contig, $segment_index, $bin, $start_index, $end_index) = @_;

    # get fragments
    defined($contigs{$contig}->{index2fragment}->{$start_index}) or die "$contig: $start_index";
    defined($contigs{$contig}->{index2fragment}->{$end_index}) or die "$contig: $end_index";
    my $start_fragment = $contigs{$contig}->{index2fragment}->{$start_index};
    my $end_fragment = $contigs{$contig}->{index2fragment}->{$end_index};

    # get fragment coords
    defined($contigs{$contig}->{fragments}->{$start_fragment}) or die;
    defined($contigs{$contig}->{fragments}->{$end_fragment}) or die;
    my $start = $contigs{$contig}->{fragments}->{$start_fragment}->{start};
    my $end = $contigs{$contig}->{fragments}->{$end_fragment}->{end};

    my $segment = $contig.":s".$segment_index;
    print OUT "$segment\t$bin\t$contig\t$start\t$end\t$start_index\t$end_index\n";
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

