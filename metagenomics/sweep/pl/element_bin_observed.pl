#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <bin table> <contig2bin> <contact map> <ifn>\n";
	exit 1;
}

my $bins_ifn = $ARGV[0];
my $contig2bin_ifn = $ARGV[1];
my $contact_ifn = $ARGV[2];
my $ofn = $ARGV[3];

#############################################################################################
# bins file
#############################################################################################

my %bins;

open(IN, $bins_ifn) || die;
print STDERR "Reading file: $bins_ifn\n";
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $bin = $f[$h{bin}];
    my $class = $f[$h{class}];
    $bins{$bin} = {};
    $bins{$bin}->{class} = $class;
    $bins{$bin}->{singleton} = 0;
}
close(IN);

#############################################################################################
# contig2bin file
#############################################################################################

my %contig2bin;

open(IN, $contig2bin_ifn) || die;
print STDERR "Reading file: $contig2bin_ifn\n";
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $bin = $f[$h{bin}];
    my $contig = $f[$h{contig}];

    if ($bin > 0) {
	$contig2bin{$contig} = $bin;
    } else {
	$bin = $contig;
	$contig2bin{$bin} = $contig;
	$bins{$bin}->{class} = "element";
	$bins{$bin}->{singleton} = 1;
    }
}
close(IN);

#############################################################################################
# contacts
#############################################################################################

my %hosts;

open(IN, $contact_ifn) || die;
print STDERR "Reading file: $contact_ifn\n";
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $contig1 = $f[$h{contig1}];
    my $contig2 = $f[$h{contig2}];
    my $count = $f[$h{contacts}];

    defined($contig2bin{$contig1}) && defined($contig2bin{$contig2}) or die;
    my $bin1 = $contig2bin{$contig1};
    my $bin2 = $contig2bin{$contig2};

    defined($bins{$bin1}) && defined($bins{$bin2}) or die;
    my $class1 = $bins{$bin1}->{class};
    my $class2 = $bins{$bin2}->{class};

    my $skip = 1;
    my $host = 0;
    my $element = 0;
    if ($class1 eq "host" && $class2 eq "element") {
	$host = $bin1;
	$element = $bin2;
	$skip = 0;
    }
    if ($class2 eq "host" && $class1 eq "element") {
	$host = $bin2;
	$element = $bin1;
	$skip = 0;
    }
    next if ($skip);

    $hosts{$host} = {} if (!defined($hosts{$host}));
    $hosts{$host}->{$element} = 0 if (!defined($hosts{$host}->{$element}));
    $hosts{$host}->{$element} += $count;
}
close(IN);

#############################################################################################
# output
#############################################################################################

print "Writing output file: $ofn\n";

open(OUT, ">", $ofn) || die;
print OUT "host\telement\telement_is_singleton\tcount\n";
foreach my $host (sort {$a <=> $b} keys %hosts) {
foreach my $element (keys %{$hosts{$host}}) {
    my $count = $hosts{$host}->{$element};
    defined($bins{$element}) or die;
    my $singleton = $bins{$element}->{singleton} ? "T" : "F";
    print OUT "$host\t$element\t$singleton\t$count\n";
} }
close(OUT);

######################################################################################################
# Subroutines
######################################################################################################

sub median {
  (sort { $a <=> $b } @_ )[ int( $#_/2 ) ];
}

sub min
{
    my ($a, $b) = @_;
    return $a < $b ? $a : $b;
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

