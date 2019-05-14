#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;
use Switch;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <ifn> <ofn>\n";
	exit 1;
}

my $ifn = $ARGV[0];
my $ofn = $ARGV[1];

######################################################################################################
# read codon table
######################################################################################################

my %codons;

print STDERR "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $codon = $f[$h{codon}];
    my $aa = $f[$h{aa}];
    my $extra = $f[$h{extra}];
    $codons{$codon} = {};
    $codons{$codon}->{aa} = $aa;
    $codons{$codon}->{extra} = $extra;
    $codons{$codon}->{key} = $aa.$extra;
    $codons{$codon}->{ka} = 0;
    $codons{$codon}->{ks} = 0;
}

######################################################################################################
# go over all subs
######################################################################################################

print STDERR "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
chomp($header);
print OUT $header,"\tka\tks\n";

my @nucs = ('A', 'C', 'G', 'T');

foreach my $src (sort keys %codons) {
    # print $src, "\n";
    for (my $i=0; $i<3; $i++) {
	for (my $j=0; $j<4; $j++) {
	    my $nuc = $nucs[$j];
	    my $tgt = $src;
	    substr($tgt,$i,1) = $nuc;
	    next if ($src eq $tgt);
	    my $key_src = $codons{$src}->{key};
	    my $key_tgt = $codons{$tgt}->{key};
	    if ($key_src eq $key_tgt) {
		$codons{$src}->{ks}++;
	    } else {
		$codons{$src}->{ka}++;
	    }
	}
    }
    print OUT $src, "\t", $codons{$src}->{aa}, "\t", $codons{$src}->{extra}, "\t", $codons{$src}->{ka}, "\t", $codons{$src}->{ks}, "\n";
}
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
