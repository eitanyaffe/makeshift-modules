#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use List::Util;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <map_ifn1> <map_ifn2> <field> <max|min> <ofn>\n";
	exit 1;
}

my ($map_ifn1, $map_ifn2, $max_field, $function, $ofn) = @ARGV;

my $self = $map_ifn1 eq $map_ifn2;

###################################################################################################################
# go over map
###################################################################################################################

# from 1 to 2
our %gmap;
read_map($map_ifn1, 1);
read_map($map_ifn2, 0);

###################################################################################################################
# output graph
###################################################################################################################

print STDERR "generating output: $ofn\n";
open(OUT, ">", $ofn) || die;
print OUT "gene_a\tgene_b\tidentity\tcoverage\n";

foreach my $gene1 (keys %gmap) {
    my $coverage1 = $gmap{$gene1}->{coverage};
    my $identity1 = $gmap{$gene1}->{identity};
    my $gene2 = $gmap{$gene1}->{target};
    my $fwd = $gmap{$gene1}->{fwd};

    next if (!$fwd || !defined($gmap{$gene2}) || $gmap{$gene2}->{target} ne $gene1);
    my $coverage2 = $gmap{$gene2}->{coverage};
    my $identity2 = $gmap{$gene2}->{identity};

    my $identity = ($identity1 + $identity2) / 2;
    my $coverage = 100 * ($coverage1 + $coverage2) / 2;
    print OUT "$gene1\t$gene2\t$identity\t$coverage\n";
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

sub read_map
{
    my ($ifn, $fwd) = @_;
    print STDERR "reading map: $ifn\n";
    open(IN, $ifn) || die;
    my $header = <IN>;
    my %h = parse_header($header);
    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $identity = $f[$h{identity}];
	my $coverage = $f[$h{coverage}];
	my $source = $f[$h{source}];
	my $target = $f[$h{target}];
	my $value = $f[$h{$max_field}];

	if ($function eq "min") {
	    $value *= -1;
	}

	if (!defined($gmap{$source})) {
	    $gmap{$source} = {};
	    $gmap{$source}->{target} = "";
	    $gmap{$source}->{value} = 0;
	    $gmap{$source}->{coverage} = 0;
	    $gmap{$source}->{identity} = 0;
	    $gmap{$source}->{fwd} = $fwd;
	}
	if ($value > $gmap{$source}->{value}) {
	    $gmap{$source}->{target} = $target;
	    $gmap{$source}->{value} = $value;
	    $gmap{$source}->{coverage} = $coverage;
	    $gmap{$source}->{identity} = $identity;
	}
    }
    close(IN);
}

