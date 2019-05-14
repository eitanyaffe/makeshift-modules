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

print STDERR "reading table: $ifn\n";
open(IN, $ifn) || die $ifn;

my $i = 0;
my ($aa,$start,$b1,$b2,$b3);
while (my $line = <IN>) {
    $i++;
    chomp $line;
    my @f = split("=", $line);
    @f == 2 or die "character '=' not found";
    switch ($i) {
	case 1 { $aa=$f[1] }
	case 2 { $start=$f[1] }
	case 3 { $b1=$f[1] }
	case 4 { $b2=$f[1] }
	case 5 { $b3=$f[1] }
    }
}
close (IN);

print "AA   : $aa\n";
print "START: $start\n";
print "Base1: $b1\n";
print "Base2: $b2\n";
print "Base3: $b3\n";

my @aa_arr = split('', $aa);
my @start_arr = split('', $start);
my @b1_arr = split('', $b1);
my @b2_arr = split('', $b2);
my @b3_arr = split('', $b3);

length($aa) == 64 or die "expecting exactly 64 codons";

print STDERR "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;

print OUT "codon\taa\textra\n";
for (my $i=0;$i<64;$i++)
{
    my $codon = $b1_arr[$i].$b2_arr[$i].$b3_arr[$i];
    print OUT $codon, "\t", $aa_arr[$i], "\t", $start_arr[$i], "\n";
}    
close(OUT);
    
