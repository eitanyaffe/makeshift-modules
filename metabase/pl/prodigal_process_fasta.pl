#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <ifn> <gene prefix> <sequence ofn> <table ofn>\n";
	exit 1;
}
my $ifn = $ARGV[0];
my $prefix = $ARGV[1];
my $ofn_seq = $ARGV[2];
my $ofn_table = $ARGV[3];

print "writing gene seq file: $ofn_seq\n";
open(OUT, $ofn_seq) || die $ofn_seq;

print "writing gene table: $ofn_table\n";
open(OUT_TABLE, $ofn_table) || die $ofn_table;

print "reading file: $ifn\n";
open(IN, $ifn) || die $ifn;

# prodigal output:
# >k147_48_1 # 1 # 492 # 1 # ID=6_1;partial=10;start_type=Edge;rbs_motif=None;rbs_spacer=None;gc_cont=0.667

while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) eq ">") {
	$li
	my $gene = $prefix.substr($line, index($line, "_"), index($line, "|")-index($line, "_"));
	print OUT ">$gene\n";
    } else {
	print OUT $line, "\n";
    }

}

close(IN);
close(OUT);
close(OUT_TABLE);

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
