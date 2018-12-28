#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <item table> <item field> <fasta input> <fasta output>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $field = $ARGV[1];
my $ifn_fasta = $ARGV[2];
my $ofn = $ARGV[3];

###############################################################################################
# read items
###############################################################################################

my %items;
print "reading item table: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $item = $f[$h{$field}];
    $items{$item} = 1;
}
close(IN);
print "Number of items: ", scalar(keys %items), "\n";

###############################################################################################
# go over all cags
###############################################################################################

print "reading fasta file: $ifn_fasta\n";
open(IN, $ifn_fasta) || die $ifn_fasta;

print "Generating fasta file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

my $include = 0;
while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) eq ">") {
	my @f = split(" ", substr($line,1));
	my $item = $f[0];
	$include = defined($items{$item});
    }
    print OUT $line,"\n" if ($include);
}
close(IN);
close(OUT);

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
