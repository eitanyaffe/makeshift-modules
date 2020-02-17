#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <GO tree> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $ifn_go_tree = $ARGV[1];
my $ofn = $ARGV[2];

###############################################################################################
# go tree
###############################################################################################

my %tree;

print STDERR "reading table: $ifn_go_tree\n";
open(IN, $ifn_go_tree) || die $ifn_go_tree;
my $header = <IN>;
my %h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $id = $f[$h{id}];
    my $desc = $f[$h{desc}];
    my $parent_ids = $f[$h{parent_ids}];
    my $is_root = $f[$h{root}] eq "T";
    $tree{$id} = {};
    $tree{$id}->{desc} = $desc;
    $tree{$id}->{parents} = $parent_ids;
    $tree{$id}->{is_root} = $is_root;
}
close(IN);

###############################################################################################
# table first pass
###############################################################################################

our %mask;

print STDERR "first pass: $ifn\n";
open(IN, $ifn) || die $ifn;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $id = $f[$h{id}];
    defined($tree{$id}) or die;
    next if ($tree{$id}->{is_root});
    my @pids = split(";", $tree{$id}->{parents});
    for my $pid (@pids) {
	mask_parents($pid);
    }
}
close(IN);

###############################################################################################
# table second pass
###############################################################################################

print STDERR "second pass: $ifn\n";
open(IN, $ifn) || die $ifn;
$header = <IN>;
%h = parse_header($header);

print STDERR "generating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT $header;

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $id = $f[$h{id}];
    next if (defined($mask{$id}));
    print OUT $line, "\n";
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

sub mask_parents
{
    my ($id) = @_;
    defined($tree{$id}) or die $id;
    $mask{$id} = 1;
    if (!$tree{$id}->{is_root}) {
	my @pids = split(";", $tree{$id}->{parents});
	for my $pid (@pids) {
	    mask_parents($pid);
	}
    }
}
