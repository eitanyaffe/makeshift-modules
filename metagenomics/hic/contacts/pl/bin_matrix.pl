#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <contact table> <contig2bin table> <bin table> <ofn>\n";
	exit 1;
}

my ($ifn_mat, $ifn_c2b, $ifn_bins, $ofn) = @ARGV;

#######################################################################################
# read bin table table
#######################################################################################

my %bins;
my %hosts;

print STDERR "reading bin table: $ifn_bins\n";
open(IN, $ifn_bins) || die $ifn_bins;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $bin = $f[$h{bin}];
    my $class = $f[$h{class}];
    $bins{$bin} = $class;
    $hosts{$bin} = {} if ($class eq "host");
}
close(IN);

#######################################################################################
# read contig2bin table
#######################################################################################

my %contigs;

print STDERR "reading contig2bin table: $ifn_c2b\n";
open(IN, $ifn_c2b) || die $ifn_c2b;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $bin = $f[$h{bin}];
    $contigs{$contig} = $bin;
}
close(IN);

#######################################################################################
# read matrix table
#######################################################################################

my %mat;

print STDERR "reading contact map: $ifn_mat\n";
open(IN, $ifn_mat) || die $ifn_mat;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig1 = $f[$h{contig1}];
    my $contig2 = $f[$h{contig2}];
    my $count = $f[$h{contacts}];

    my $bin1 = defined($contigs{$contig1}) ? $contigs{$contig1} : $contig1;
    my $bin2 = defined($contigs{$contig2}) ? $contigs{$contig2} : $contig2;
    next if ($bin1 eq $bin2);

    if (defined($hosts{$bin1})) {

	my $host = $bin1;
	my $bin = $bin2;

	$mat{$host} = {} if (!defined($mat{$host}));
	$mat{$host}->{$bin} = 0 if (!defined($mat{$host}->{$bin}));

	$mat{$host}->{$bin} += $count/2;
    }

    if (defined($hosts{$bin2})) {

	my $host = $bin2;
	my $bin = $bin1;

	$mat{$host} = {} if (!defined($mat{$host}));
	$mat{$host}->{$bin} = 0 if (!defined($mat{$host}->{$bin}));

	$mat{$host}->{$bin} += $count/2;
    }

}
close(IN);

#######################################################################################
# output matrix
#######################################################################################

print "generating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "host\tbin\ttype\tcount\n";
foreach my $host (keys %mat) {
    foreach my $bin (keys %{$mat{$host}}) {
	my $count = $mat{$host}->{$bin};
	my $type = defined($bins{$bin}) ? $bins{$bin} : "contig";
	print OUT "$host\t$bin\t$type\t$count\n";
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
