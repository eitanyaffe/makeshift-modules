#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn1> <ifn2> <odir>\n";
	exit 1;
}

my $ifn1 = $ARGV[0];
my $ifn2 = $ARGV[1];
my $odir = $ARGV[2];

my @fields = ("REF", "A", "C", "G", "T");
my @all_fields = ("REF1", "A1", "C1", "G1", "T1", "total1", "REF2", "A2", "C2", "G2", "T2", "total2");

###############################################################################################
# traverse ifn1
###############################################################################################

my %anchors;

foreach my $ifn (($ifn1, $ifn2)) {
    my $count = 0;
    print STDERR "reading file: $ifn\n";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    my %h = parse_header($header);
    my $label = ($ifn eq $ifn1) ? "1" : "2";
    while (my $line = <IN>) {
	chomp $line;
	my @f = split("\t", $line);
	my $anchor = $f[$h{anchor}];
	my $contig = $f[$h{contig}];
	my $coord = $f[$h{coord}];
	$anchors{$anchor} = {} if (!defined($anchors{$anchor}));
	$anchors{$anchor}->{$contig} = {} if (!defined($anchors{$anchor}->{$contig}));
	$anchors{$anchor}->{$contig}->{$coord} = {} if (!defined($anchors{$anchor}->{$contig}->{$coord}));
	my $total = 0;
	foreach my $field (@fields) {
	    $anchors{$anchor}->{$contig}->{$coord}->{$field.$label} =  $f[$h{$field}];
	    $total += $f[$h{$field}];
	}
	$anchors{$anchor}->{$contig}->{$coord}->{"total".$label} = $total;

	$count++;
	print "line: $count\n" if ($count % 1000000 == 0);
    }
    close(IN);
}

######################################################################################################
# output
######################################################################################################

foreach my $anchor (keys %anchors) {
    my $ofn = $odir."/".$anchor;
    open(OUT, ">", $ofn) || die $ofn;
    print STDERR "generating file: $ofn\n";
    print OUT "contig\tcoord";
    foreach my $field (@all_fields) {
	print OUT "\t", $field;
    }
    print OUT "\n";
    foreach my $contig (sort keys %{$anchors{$anchor}}) {
    foreach my $coord (sort {$a <=> $b} keys %{$anchors{$anchor}->{$contig}}) {
	print OUT $contig, "\t", $coord;
	foreach my $field (@all_fields) {
	    print OUT "\t", defined($anchors{$anchor}->{$contig}->{$coord}->{$field}) ?
		$anchors{$anchor}->{$contig}->{$coord}->{$field} : -1;
	}
	print OUT "\n";
    } }
    close(OUT);
}

######################################################################################################
# Subroutines
######################################################################################################


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
