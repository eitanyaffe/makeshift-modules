#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use List::Util qw(sum);

if ($#ARGV == -1) {
    print STDERR "usage: $0 <anchor/ref table> <contig table> <gene table> <anchor/gene table> <fragment length> <input dir> <ofn>\n";
	exit 1;
}

my @pnames = ("ifn_ref",
	      "ifn_contigs",
	      "ifn_genes",
	      "ifn_anchor_gene",
	      "frag_length",
	      "idir",
	      "ofn"
    );
my %p;
@p{@pnames} = @ARGV;

print "=============================================\n";
foreach my $key (keys %p) {
    defined($p{$key}) or die "parameter $key not defined (check if all parameters defined)";
    print $key, ": ", $p{$key}, "\n";
}
print "=============================================\n";

#######################################################################################
# read contig table
#######################################################################################

my %contigs;
print "reading contig table: $p{ifn_contigs}\n";
open(IN, $p{ifn_contigs}) || die;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    $contigs{$f[$h{contig}]} = $f[$h{length}];
}
close(IN);

#######################################################################################
# read anchor/ref table
#######################################################################################

my %anchors;

print "reading anchor/ref table: $p{ifn_ref}\n";
open(IN, $p{ifn_ref}) || die;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $anchor = $f[$h{anchor}];
    my $ref = $f[$h{ref}];
    $anchors{$anchor} = {};
    $anchors{$anchor}->{ref} = $ref;
    $anchors{$anchor}->{id} = $f[$h{"anchor.id"}];

    $anchors{$anchor}->{contigs} = {};

    my $ifn = $p{idir}. "/".$anchor."_".$ref."/src_table";
    open(RIN, $ifn) || die;
    my $rheader = <RIN>;
    my %rh = parse_header($rheader);
    while (my $rline = <RIN>) {
	chomp($rline);
	my @rf = split("\t", $rline);
	my $contig = $rf[$rh{contig}];
	my $coord = $rf[$rh{coord}];
	my $edit = $rf[$rh{edit_distance}];
	$anchors{$anchor}->{contigs}->{$contig}[$coord] = $edit;
#	if (!defined($anchors{$anchor}->{contigs}->{$contig})) {
#	    my @arr
#	    $anchors{$anchor}->{contigs}->{$contig} = \@arr;
#	$anchors{$anchor}->{contigs}->{$contig}->{$coord} = $edit;
    }
    close(RIN);
}
close(IN);

#######################################################################################
# read gene table
#######################################################################################

my %genes;

print "reading gene table: $p{ifn_genes}\n";
open(IN, $p{ifn_genes}) || die;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    $genes{$gene} = {};
    $genes{$gene}->{contig} = $f[$h{contig}];
    $genes{$gene}->{start} = $f[$h{start}];
    $genes{$gene}->{end} = $f[$h{end}];
}
close(IN);

#######################################################################################
# traverse anchor/gene table
#######################################################################################

print "reading anchor/gene table: $p{ifn_anchor_gene}\n";
open(IN, $p{ifn_anchor_gene}) || die;
$header = <IN>;
%h = parse_header($header);

print "writing table: $p{ofn}\n";
open(OUT, ">", $p{ofn}) || die;
print OUT "anchor.id\tanchor\tgene\tcoverage\tidentity\n";
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    my $anchor = $f[$h{anchor}];
    defined($genes{$gene}) && defined($anchors{$anchor}) || die;

    my $ref = $anchors{$anchor}->{ref};
    my $id = $anchors{$anchor}->{id};

    my $contig = $genes{$gene}->{contig};
    my $start = $genes{$gene}->{start};
    my $end = $genes{$gene}->{end};

    my $length = $end - $start + 1;

    my $count = 0;
    my $sum = 0;
    for (my $coord=$start; $coord<=$end; $coord++) {
	# defined($anchors{$anchor}->{contigs}->{$contig}->{$coord}) || die;
	# my $edit = $anchors{$anchor}->{contigs}->{$contig}->{$coord};
	defined($anchors{$anchor}->{contigs}->{$contig}) || die;
	my $edit = $anchors{$anchor}->{contigs}->{$contig}[$coord];
	next if ($edit == -1);
	$count++;
	$sum+= 1 - $edit/$p{frag_length};
    }
    my $coverage = $count / $length;
    my $identity = $count > 0 ? $sum/$count : 0;

    print OUT "$id\t$anchor\t$gene\t$coverage\t$identity\n";
}
close(IN);

#######################################################################################
# utils
#######################################################################################

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
