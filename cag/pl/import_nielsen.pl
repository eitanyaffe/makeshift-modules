#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <input genes> <input dir> <omit MGS T|F> <output fasta> <output map>\n";
	exit 1;
}

my $igenes = $ARGV[0];
my $idir = $ARGV[1];
my $omit_mgs = $ARGV[2];
my $ofasta = $ARGV[3];
my $ogenes = $ARGV[4];

###############################################################################################
# read cag/gene map for cags
###############################################################################################

my %cags;
print "reading gene file: $igenes\n";
open(IN, $igenes) || die $igenes;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $cag = $f[0];
    $cag =~ s/CAG://;
    $cags{$cag} = 0;
}
close(IN);
print "Number of CAGs: ", scalar(keys %cags), "\n";

###############################################################################################
# go over all cags
###############################################################################################

print "Generating gene table: $ogenes\n";
open(OUT_GENES, ">", $ogenes) || die $ogenes;
print OUT_GENES "gene\tlength\taa_length\tset\ttype\n";

print "Generating single fasta file: $ofasta\n";
open(OUT_FASTA, ">", $ofasta) || die $ofasta;

for my $cag (sort {$a <=> $b} keys %cags) {
    my $ifn_cag = $idir."/CAG:".$cag.".fna";
    my $ifn_mgs = $idir."/MGS:".$cag.".fna";
    (-e $ifn_cag || -e $ifn_mgs) or die "MGS or CAG file do not exist for CAG:".$cag;
    my $type = (-e $ifn_cag) ? "CAG" : "MGS";
    my $ifn = ($type eq "CAG") ? $ifn_cag : $ifn_mgs;

    next if ($omit_mgs eq "T" && $type eq "MGS");

    my $seq = "";
    my $gene = "";
    open(IN, $ifn) || die $ifn;
    while (my $line = <IN>) {
	chomp($line);
	if (substr($line, 0, 1) ne ">") {
	    $seq .= $line;
	} else {
	    if ($gene ne "") {
		print OUT_GENES $gene, "\t", length($seq), "\t", length($seq)/3, "\t", $cag, "\t", $type, "\n" ;
		print OUT_FASTA ">", $gene, "\n", $seq, "\n";
	    }
	    my @f = split(" ", substr($line,1));
	    $gene = $cag."_".$f[0];
	    $seq = "";
	}
    }
    if ($gene ne "") {
	print OUT_GENES $gene, "\t", length($seq), "\t", length($seq)/3, "\t", $cag, "\t", $type, "\n" ;
	print OUT_FASTA ">", $gene, "\n", $seq, "\n";
    }
    close(IN);
}

close(OUT_GENES);
close(OUT_FASTA);

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
