#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
        print "usage: $0 <fasta> <bin table> <contig table> <odir>\n";
        exit 1;
}

my $ifn_fasta = $ARGV[0];
my $ifn_bin_table = $ARGV[1];
my $ifn_contig_table = $ARGV[2];
my $odir = $ARGV[3];

####################################################################################
# load contigs
####################################################################################

my %contigs;

my $seq = "";
my $contig = "";
print "reading fasta file: $ifn_fasta\n";
open(IN, $ifn_fasta) or die $ifn_fasta;
while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) ne ">") {
	$seq .= $line;
    } else {
	$contigs{$contig} = $seq if ($contig ne "");
	my @f = split(" ", substr($line,1));
	$contig = $f[0];
	$seq = "";
    }
}
$contigs{$contig} = $seq if ($contig ne "");
close(IN);

####################################################################################
# read bin table
####################################################################################

my %bins;
print "reading bin table: $ifn_bin_table\n";
open(IN, $ifn_bin_table) || die $ifn_bin_table;

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $bin = $f[$h{bin}];
    $bins{$bin} = {};

}
close(IN);

####################################################################################
# read contig table
####################################################################################

print "reading contig table: $ifn_contig_table\n";
open(IN, $ifn_contig_table) || die $ifn_contig_table;

$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $bin = $f[$h{bin}];
    $bins{$bin}->{$contig} = 1 if (defined($bins{$bin}));
}
close(IN);

####################################################################################
# output bin fasta
####################################################################################

print "writing fasta into directory: $odir\n";
foreach my $bin (keys %bins) {
    my $ofn = $odir."/".$bin.".fasta";
    open(OUT, ">", $ofn) || die $ofn;
    foreach my $contig (keys %{$bins{$bin}}) {
	print OUT ">$contig\n";
	defined($contigs{$contig}) or die;
	my $seq = $contigs{$contig};
	my @lines = unpack("(A80)*", $seq);
	foreach my $line (@lines) {
	    print OUT $line, "\n";
	}
    }
}
close(OUT);

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

