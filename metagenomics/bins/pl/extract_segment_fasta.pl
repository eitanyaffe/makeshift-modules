#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
        print "usage: $0 <fasta> <segment table> <ofn>\n";
        exit 1;
}

my $ifn_fasta = $ARGV[0];
my $ifn_table = $ARGV[1];
my $ofn = $ARGV[2];

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
# process segments
####################################################################################

print "reading segment table: $ifn_table\n";
open(IN, $ifn_table) || die $ifn_table;

print "writing fasta file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $id = $f[$h{contig}];
    my $contig = $f[$h{"contig.org"}];
    my $start = $f[$h{"start.org"}];
    my $end = $f[$h{"end.org"}];
    my $length = $end - $start + 1;

    defined($contigs{$contig}) or die;
    my $seq = $contigs{$contig};

    my $seg_seq = substr($seq,$start,$length);
    print OUT ">$id\n";
    my @lines = unpack("(A80)*", $seg_seq);
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

