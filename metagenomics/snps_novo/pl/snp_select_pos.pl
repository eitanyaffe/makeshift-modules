#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <selected ifn> <prefix input> <prefix output>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $prefix_in = $ARGV[1];
my $prefix_out = $ARGV[2];

#######################################################################################
# read selected positions into memory
#######################################################################################

my %contigs;

print "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;

my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig  = $f[$h{contig}];
    my $coord  = $f[$h{coord}];
    $contigs{$contig} = {} if (!defined($contigs{$contig}));
    $contigs{$contig}->{$coord} = 1 if (!defined($contigs{$contig}->{$coord}));
}
close(IN);

#######################################################################################
# read matrix into memory
#######################################################################################

my @exts = ("A", "C", "G", "T", "total");
for (my $i=0; $i<5; $i++) {
    my $ifn = $prefix_in.".".$exts[$i];
    my $ofn = $prefix_out.".".$exts[$i];

    print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;

    print "writing table: $ofn\n";
    open(OUT, ">", $ofn) || die $ofn;

    my $header = <IN>;
    my %h = parse_header($header);
    print OUT $header;

    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $contig  = $f[$h{contig}];
	my $coord  = $f[$h{coord}];

	next if (!defined($contigs{$contig}) || !defined($contigs{$contig}->{$coord}));
	print OUT $line, "\n";
    }
    close(IN);
    close(OUT);
}

#######################################################################################
# utils
#######################################################################################

sub median
{
    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;
    if($len%2) #odd?
    {
        return $vals[int($len/2)];
    }
    else #even
    {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}

sub apprx_lines
{
	my ($fn) = @_;
	my $tmp = "/tmp/".$$."_apprx_lines.tmp";
	system("head -n 100000 $fn > $tmp");
	my $size_head = -s $tmp;
	my $size_all = -s $fn;
	return (int($size_all/$size_head*100000));
}

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

# returns first element above/below value in sorted array
sub binary_search
{
    my $arr = shift;
    my $value = shift;
    my $above = shift;

    my $left = 0;
    my $right = $#$arr;

    while ($left <= $right) {
	my $mid = ($right + $left) >> 1;
	my $c = $arr->[$mid] <=> $value;
	return $mid if ($c == 0);
	if ($c > 0) {
	    $right = $mid - 1;
	} else {
	    $left  = $mid + 1;
	}
    }
    $left = -1 if ($left > $#$arr);
    $right = -1 if ($right < 0);
    return ($above ? $left : $right);
}
