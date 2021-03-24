#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $ofn = $ARGV[1];

###############################################################################################
# traverse ifn
###############################################################################################

print STDERR "generating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "contig\tcoord\tsequence\tcount\ttotal\n";

my @labels = ("REF", "A", "C", "G", "T");
print STDERR "reading file: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my @data = ($f[$h{REF}], $f[$h{A}], $f[$h{C}], $f[$h{G}], $f[$h{T}]);
    my ($idxMax,$total) = (0,0);
    $data[$idxMax] > $data[$_] or $idxMax = $_ for 0 .. $#data;
    $total += $data[$_] for 0 .. $#data;

    if ($labels[$idxMax] ne "REF") {
	print OUT $contig, "\t", $coord, "\t", $labels[$idxMax], "\t", $data[$idxMax], "\t", $total, "\n";
    }
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
