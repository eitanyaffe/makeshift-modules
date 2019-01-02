#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <snp ifn> <anchor ifn> <ofn>\n";
	exit 1;
}

my $snp_ifn = $ARGV[0];
my $ca_ifn = $ARGV[1];
my $ofn = $ARGV[2];

###############################################################################################
# traverse ca_ifn
###############################################################################################

my %contigs;
print STDERR "reading file: $ca_ifn\n";
open(IN, $ca_ifn) || die $ca_ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $contig_anchor = $f[$h{contig_anchor}];
    my $anchor = $f[$h{anchor}];
    next if ($contig_anchor ne $anchor);
    $contigs{$contig} = $anchor;
}
close(IN);

###############################################################################################
# traverse snp_ifn
###############################################################################################

my $count = 0;
my %anchors;
print STDERR "reading file: $snp_ifn\n";
open(IN, $snp_ifn) || die $snp_ifn;
$header = <IN>;
%h = parse_header($header);

open(OUT, ">", $ofn) || die $ofn;
print STDERR "generating file: $ofn\n";
print OUT "anchor\t", $header;

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    next if (!defined($contigs{$contig}));
    my $anchor = $contigs{$contig};

    $anchors{$anchor} = {} if (!defined($anchors{$anchor}));
    $anchors{$anchor}->{$contig} = {} if (!defined($anchors{$anchor}->{$contig}));
    !defined($anchors{$anchor}->{$contig}->{$coord}) or die;
    print OUT $anchor, "\t", $line, "\n";
    $count++;
    # last if ($count == 1000000);
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
