#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <read_length> <cutter_length> <max reads> <report top>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $read_length = $ARGV[1];
my $cutter_length = $ARGV[2];
my $max_reads = $ARGV[3];
my $report_top = $ARGV[4];

print "traversing read file: $ifn\n";
open(IN, $ifn) || die $ifn;

my %htable;
my $total_count = 0;
while (my $line = <IN>) {
    chomp($line);

    # skip comments
    next if (substr($line, 0, 1) eq "@");

    $total_count++;
    
    my @f = split(/\s+/, $line);
    my $id = $f[0];
    my $flag = $f[1];
    my $contig = $f[2];
    my $coord = $f[3];
    my $score = $f[4];
    my $cigar = $f[5];
    my $seq = $f[9];

    my $strand = ($flag & 16) ? -1 : 1;

    # skip all kinds of bad reads
    my $multi_segments = ($flag & 1);
    my $unmapped = ($flag & 4);
    my $duplicate = ($flag & 1024);
    if ($multi_segments || $unmapped || $duplicate) {
	next;
    }

    # skip if all of read mapped or if score is low
    next if (length($seq) eq $read_length || $score < 60);

    my  $seq_end = substr($seq, -$cutter_length);
    $htable{$seq_end}++;
    last if ($total_count > $max_reads && $max_reads > 0);
}
close(IN);

my $site_count = 0;
foreach my $site (sort { $htable{$b} <=> $htable{$a} } keys %htable) {
    my $count = $htable{$site};
    my $percent = 100*($count/$total_count);
    print "** site: $site\n";
    print "   count: $count\n";
    print "   percent: $percent\n";
    last if (++$site_count >= $report_top);
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
