#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <idir> <odir> <id1 id2 ...>\n";
	exit 1;
}

my $idir = $ARGV[0];
my $ifn = $ARGV[1];
my $odir = $ARGV[2];
shift; shift; shift;
my @ids = @ARGV;

print "processing ids: ", join(",", @ids), "\n";

###################################################################################################################
# gene segments
###################################################################################################################

my %contigs;

print "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $length = $f[$h{length}];
    $contigs{$contig} = $length;
}
close(IN);

###################################################################################################################
# go over contigs
###################################################################################################################

print "number of contigs: ", scalar keys %contigs, "\n";

my $count = 0;
print "writing output to directory: $odir\n";
foreach my $contig (keys %contigs) {
    my $ofn = $odir."/".$contig;
    open(OUT, ">", $ofn) || die $ofn;
    print "progress: ",$count-1, " contigs\n" if ($count++ % 10000 == 0);
    my $length = $contigs{$contig};
    my @coverage_vector = (0) x $length;

    foreach my $id (@ids) {
	my $ifn = sprintf("%s/%s/vari/output_full/%s.cov", $idir, $id, $contig);
	open(IN, $ifn) || die $ifn;
	my $index = 0;
	while (my $line = <IN>) {
	    $coverage_vector[$index++] += $line;
	}
	close(IN);
    }
    for (my $i=0; $i<$length; $i++) {
	print OUT $coverage_vector[$i], "\n";
    }
}
close(OUT);

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
