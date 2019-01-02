#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;
$| = 1;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <idir> <input file pattern> <odir>\n";
	exit 1;
}

my ($idir, $pattern, $odir) = @ARGV;

#######################################################################################
# populate hashtable with all reads
#######################################################################################

my %map;

my $oheader;
print "searching for input files: $idir/$pattern\n";
my @ifns = <$idir/$pattern>;
print "number of input files: ", scalar(@ifns), "\n";
for my $ifn (@ifns) {
    print "loading read table into memory: $ifn\n";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    $oheader = $header;
    # print ".";
    my %h = parse_header($header);
    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);

	my $contig1 = $f[$h{contig1}];
	my $contig2 = $f[$h{contig2}];
	my $id = $f[$h{id}];

	$map{$contig1} = {} if (!defined($map{$contig1}));
	$map{$contig1}->{$contig2} = {} if (!defined($map{$contig1}->{$contig2}));
	$map{$contig1}->{$contig2}->{$id} = $line;

	if ($contig1 ne $contig2) {
	    $map{$contig2}->{$contig1} = {} if (!defined($map{$contig2}->{$contig1}));
	    $map{$contig2}->{$contig1}->{$id} = $line;
	}
    }
    close(IN);
}
print ".\n";

#######################################################################################
# traverse hashtable and dump reads
#######################################################################################

print "number of contigs: ", scalar(keys %map), "\n";
print "generating files in directory: $odir\n";
for my $contig1 (keys %map) {
    # cis
    if (defined($map{$contig1}->{$contig1})) {
	my $ofn_cis = $odir."/".$contig1.".cis";
	open(OUT_CIS, ">", $ofn_cis) || die $ofn_cis;
	print OUT_CIS $oheader;
	for my $id (keys %{$map{$contig1}->{$contig1} }) {
	    print OUT_CIS $map{$contig1}->{$contig1}->{$id}, "\n";
	}
	close(OUT_CIS);
	delete($map{$contig1}->{$contig1});
    }

    # trans
    my @ocontigs = keys %{ $map{$contig1} };
    next if (scalar(@ocontigs) == 0);

    my $ofn_trans = $odir."/".$contig1.".trans";
    open(OUT_TRANS, ">", $ofn_trans) || die $ofn_trans;
    print OUT_TRANS $oheader;

    for my $contig2 (@ocontigs) {
	for my $id (keys %{$map{$contig1}->{$contig2} }) {
	    print OUT_TRANS $map{$contig1}->{$contig2}->{$id}, "\n";
	}
    }
    close(OUT_TRANS);
}

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
