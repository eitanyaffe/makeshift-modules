#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
        print "usage: $0 <contig table> <fasta> <idir> <ofn>\n";
        exit 1;
}

my $ifn_fasta = $ARGV[0];
my $ifn_table = $ARGV[1];
my $idir = $ARGV[2];
my $ofn = $ARGV[3];

####################################################################################
# go over contig table
####################################################################################

my %contigs;

print "reading fragment table: $ifn_table\n";
open(IN, $ifn_table) || die $ifn_table;

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    $contigs{$contig} = {};
}

####################################################################################
# load contig seq
####################################################################################

my $seq = "";
my $contig = "";
print "reading fasta file: $ifn_fasta\n";
open(IN, $ifn_fasta) or die $ifn_fasta;
while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) ne ">") {
	$seq .= $line;
    } else {
	$contigs{$contig}->{seq} = $seq if ($contig ne "" && defined($contigs{$contig}));
	my @f = split(" ", substr($line,1));
	$contig = $f[0];
	$seq = "";
    }
}
$contigs{$contig}->{seq} = $seq if ($contig ne "" && defined($contigs{$contig}));
close(IN);

####################################################################################
# go over variation tables
####################################################################################

print "reading from directory: $ifn_table\n";
open(IN, $ifn_table) || die $ifn_table;

print "writing fragment fasta file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $id = $f[$h{fragment_id}];
    my $start = $f[$h{start}];
    my $length = $f[$h{fragment_length}];

    defined($contigs{$contig}) or die;
    my $seq = $contigs{$contig};

    my $frag_seq = substr($seq,$start,$length);
    print OUT ">$id\n";
    my @lines = unpack("(A80)*", $frag_seq);
    foreach my $line (@lines) {
	print OUT $line, "\n";
    }
}
close(IN);
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

