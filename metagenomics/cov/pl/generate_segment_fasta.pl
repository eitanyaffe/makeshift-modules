#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);


if ($#ARGV == -1) {
        print "usage: $0 <fasta> <fragment table> <ofn>\n";
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
# process fragments
####################################################################################

print "reading fragment table: $ifn_table\n";
open(IN, $ifn_table) || die $ifn_table;

print "writing fragment fasta file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $segment = $f[$h{segment}];
    my $contig = $f[$h{contig}];
    my $start = $f[$h{start}] - 1;
    my $end = $f[$h{end}] - 1;
    my $is_outlier = $f[$h{is_outlier}];

    my $length = $end - $start + 1;

    defined($contigs{$contig}) or die;
    my $seq = $contigs{$contig};

    # sanity
    ($start + $length) <= length($seq) or die "segment: $segment, $start + $length > ".length($seq)."\n".$seq;

    my $frag_seq = substr($seq,$start,$length);
    print OUT ">$segment\n";
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

