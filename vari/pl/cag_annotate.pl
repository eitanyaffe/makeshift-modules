#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <input map> <map item field> <map group field> <ifn> <ofn> <explode dir> <label>\n";
	exit 1;
}

my $map = $ARGV[0];
my $map_item_field = $ARGV[1];
my $map_group_field = $ARGV[2];
my $ifn = $ARGV[3];
my $ofn = $ARGV[4];
my $odir = $ARGV[5];
my $label = $ARGV[6];

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

print "reading file: $ifn\n";
open(IN, $ifn) || die $ifn;
$header = <IN>;
%h = parse_header($header);
chomp($header);

print "Generating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT $header, "\tgroup\n";

my $prev_group = "";
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $item = $f[$h{contig}];
    defined($items{$item}) or die;
    my $group = $items{$item};

    if ($prev_group ne $group) {
	close(OUT_GROUP) if ($prev_group ne "");
	my $odir_group = $odir."/".$group;
	system("mkdir -p ".$odir_group);
	my $ofn_group = $odir_group."/".$label;
	open(OUT_GROUP, ">", $ofn_group) || die $ofn_group;
	print OUT_GROUP $header, "\tgroup\n";
    }
    $prev_group = $group;
    print OUT $line, "\t", $group, "\n";
    print OUT_GROUP $line, "\t", $group, "\n";
}
close(IN);
close(OUT);
close(OUT_GROUP);

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
