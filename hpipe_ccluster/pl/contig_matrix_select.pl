#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <input contig table> <input matrix> <min length> <min marginal> <output matrix>\n";
	exit 1;
}

my ($itable, $imatrix, $min_length, $min_marginal, $omatrix) = @ARGV;

#######################################################################################
# read contig table
#######################################################################################

# contig length table
my %contigs;

print "reading contig table: $itable\n";
open(IN, $itable) || die $itable;
my $header = <IN>;
my %h = parse_header($header);
my $counter = 0;
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig = $f[$h{contig}];
    my $length = $f[$h{length}];
    next if ($length < $min_length);
    $contigs{$contig} = 0;
    $counter++;
}
close(IN);
print "number of contigs: $counter\n";

#######################################################################################
# read matrix to compute marginal
#######################################################################################

print "reading matrix: $imatrix\n";
open(IN, $imatrix) || die $imatrix;
$header = <IN>;
%h = parse_header($header);
$counter= 0;
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig1 = $f[$h{contig1}];
    my $contig2 = $f[$h{contig2}];
    my $count = $f[$h{contacts}];
    next if (($contig1 eq $contig2) || !defined($contigs{$contig1}) || !defined($contigs{$contig2}) || $count == 0);

    $counter++;
    $contigs{$contig1}++;
    $contigs{$contig2}++;
}
close(IN);

$counter > 0 or die "no contacts passed filter";
print "number of contacts: $counter\n";

#######################################################################################
# output matrix
#######################################################################################

print "writing matrix: $omatrix\n";
open(OUT, ">", $omatrix) || die $omatrix;

open(IN, $imatrix) || die $imatrix;
$header = <IN>;
%h = parse_header($header);
print OUT $header;

while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);

    my $contig1 = $f[$h{contig1}];
    my $contig2 = $f[$h{contig2}];
    my $count = $f[$h{contacts}];

    next if ($contig1 eq $contig2);
    next if (!defined($contigs{$contig1}) || !defined($contigs{$contig2}) || $count == 0);
    next if (($contigs{$contig1} < $min_marginal) || ($contigs{$contig2} < $min_marginal));

    print OUT $line, "\n";
}
close(OUT);
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
