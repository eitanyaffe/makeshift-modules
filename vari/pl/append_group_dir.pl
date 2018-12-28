#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <input map> <map item field> <map group field> <idir> <odir> <label>\n";
	exit 1;
}

my $map = $ARGV[0];
my $map_item_field = $ARGV[1];
my $map_group_field = $ARGV[2];
my $idir = $ARGV[3];
my $odir = $ARGV[4];
my $label = $ARGV[5];

###############################################################################################
# read item map
###############################################################################################

my %items;
print "reading item file: $map\n";
open(IN, $map) || die $map;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $item = $f[$h{$map_item_field}];
    my $group = $f[$h{$map_group_field}];
    $items{$item} = $group;
}
close(IN);

###############################################################################################
# go over all groups
###############################################################################################

my @ifns = <$idir/*>;

for my $ifn (@ifns) {
    print "reading file: $ifn\n";
    open(IN, $ifn) || die $ifn;
    $header = <IN>;
    %h = parse_header($header);
    chomp($header);
    my $odir_group = $odir."/".$group;
    my $ofn_group = $odir_group."/".$label;

    print "Generating file: $ofn\n";
    exit(1);
    open(OUT, ">", $ofn) || die $ofn;
    print OUT $header, "\tgroup\n";

    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $item = $f[$h{contig}];
	defined($items{$item}) or die;
	my $group = $items{$item};
	print OUT $line, "\t", $group, "\n";
    }
    close(IN);
    close(OUT);
}

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
