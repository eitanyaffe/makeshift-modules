#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
        print "usage: $0 <ifn> <fasta> <ofn>\n";
        exit 1;
}

my $ifn = $ARGV[0];
my $ifn_fasta = $ARGV[1];
my $ofn = $ARGV[2];

####################################################################################
# load contig seq
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
print "number of contigs: ", scalar(keys %contigs), "\n";

####################################################################################
# go over variation tables
####################################################################################

print "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;

print "writing file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "contig\tcoord\tA\tC\tG\tT\n";

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $sA = $f[$h{sub_A}];
    my $sC = $f[$h{sub_C}];
    my $sG = $f[$h{sub_G}];
    my $sT = $f[$h{sub_T}];
    my $ref = $f[$h{ref}];

    defined($contigs{$contig}) or die $contig;
    my $seq = $contigs{$contig};
    my $nt = substr($seq,$coord-1,1);

    my $A = ($nt eq "A") ? $ref : $sA;
    my $C = ($nt eq "C") ? $ref : $sC;
    my $G = ($nt eq "G") ? $ref : $sG;
    my $T = ($nt eq "T") ? $ref : $sT;

    print OUT $contig, "\t", $coord, "\t", $A, "\t", $C, "\t", $G, "\t", $T, "\n";
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

