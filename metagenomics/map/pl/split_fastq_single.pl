#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print "usage: $0 <output dir> <max reads per file> <should trim> <trim read offset1> <trim read length1>  <trim read offset2> <trim read length2> <max reads> <ofn stats> <input fastq files/dirs>\n";
	exit 1;
}

my $odir = $ARGV[0];
my $max_reads_per_file = $ARGV[1];
my $trim = $ARGV[2] eq "T";
my $offset1 = $ARGV[3];
my $rlen1 = $ARGV[4];
my $offset2 = $ARGV[5];
my $rlen2 = $ARGV[6];
my $total_max_reads = $ARGV[7];
my $ofn_stats = $ARGV[8];
shift; shift; shift; shift; shift; shift; shift; shift; shift;
my @inputs = @ARGV;
scalar (@inputs) > 0 or die "no input files defined (check MAP_INPUT is defined)";

my @ifns;
for my $input (@inputs) {
    if (-d $input) {
	push(@ifns, <$input/*fastq>);
    } else {
	push(@ifns, $input);
    }
}
scalar (@ifns) > 0 or die "no input files found";

my $oindex = 1;
my $ofn = $odir."/".$oindex.".fastq";

print "reads per split file: $max_reads_per_file\n";
print "total reads: ", $total_max_reads ? $total_max_reads : "all", "\n";

open(OUT, ">", $ofn) or die;
print "output file: $ofn\n";

my $read_count = 0;
my $total_read_count = 0;
foreach my $ifn (@ifns) {
    open(IN, $ifn) or die;
    my $iindex = 0;
    while () {
	my $line = <IN>;
	last if (!defined($line));
	chomp($line);

	$line = substr($line, $offset1, $rlen1) if ($trim && $iindex % 2 == 1);
 	$iindex++;

	print OUT $line, "\n";
	if ($iindex % 4 == 0) {
	    $read_count++;
	    $total_read_count++;

	    last if ($total_read_count >= $total_max_reads && $total_max_reads);

	    if ($read_count >= $max_reads_per_file) {
		$read_count = 0;
		close(OUT);
		$oindex++;
		$ofn = $odir."/".$oindex.".fastq";
		open(OUT, ">", $ofn) or die;
		print "output file: $ofn\n";
	    }
	}
    }
}
close(OUT);

my %stats;
$stats{input} = $total_read_count;

print_hash($ofn_stats, %stats);

sub print_hash
{
    my ($ofn, %h) = @_;

    print STDERR "generating file: $ofn\n";
    open (OUT, ">", $ofn) || die $ofn;

    my $first = 1;
    foreach my $key (keys %h) {
	if ($first) {
	    print OUT $key;
	    $first = 0;
	} else {
	    print OUT "\t", $key;
	}
    }
    print OUT "\n";
    $first = 1;
    foreach my $key (keys %h) {
	if ($first) {
	    print OUT $h{$key};
	    $first = 0;
	} else {
	    print OUT "\t", $h{$key};
	}
    }
    print OUT "\n";
    close(OUT);
}
