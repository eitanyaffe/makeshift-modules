#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <contig table> <ifn base> <idir base> <ifn set> <idir set> <ofn>\n";
	exit 1;
}

my $ifn_contigs = $ARGV[0];
my $ifn_base = $ARGV[1];
my $idir_base = $ARGV[2];
my $ifn_set = $ARGV[3];
my $idir_set = $ARGV[4];
my $ofn = $ARGV[5];

###################################################################################################################
# load contig table
###################################################################################################################

my %contigs;

print "reading table: $ifn_contigs\n";
open(IN, $ifn_contigs) || die $ifn_contigs;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $length = $f[$h{length}];
    $contigs{$contig} = {};
    $contigs{$contig}->{length} = $length;
    $contigs{$contig}->{coords} = {};
}
close(IN);

###################################################################################################################
# load tables
###################################################################################################################

foreach my $type (("base", "set")) {
    my $ifn = $type eq "base" ? $ifn_base : $ifn_set;
    print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    my %h = parse_header($header);
    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $contig = $f[$h{contig}];
	my $coord = $f[$h{coord}];
	my $ref = $f[$h{ref}];

	defined($contigs{$contig}) or die;
	$contigs{$contig}->{coords}->{$coord} = {} if (!defined($contigs{$contig}->{coords}->{$coord}));
	$contigs{$contig}->{coords}->{$coord}->{$type} = {} if (!defined($contigs{$contig}->{coords}->{$coord}->{$type}));
	foreach my $nt (("A", "C", "G", "T")) {
	    $contigs{$contig}->{coords}->{$coord}->{$type}->{$nt} = $f[$h{$nt}];
	}

	$contigs{$contig}->{coords}->{$coord}->{ref} = $ref if (!defined($contigs{$contig}->{coords}->{$coord}->{ref}));
	($contigs{$contig}->{coords}->{$coord}->{ref} eq $ref) or die "ref nt does not match between base and set files";
    }
}

###################################################################################################################
# add nt coverage where needed
###################################################################################################################

foreach my $type (("base", "set")) {
    my $count = 0;
    print "appending $type contig coverages, number of contigs: ", scalar keys %contigs, "\n";
    my $idir = $type eq "base" ? $idir_base : $idir_set;
    foreach my $contig (keys %contigs) {
	print "progress: ",$count, " contigs\n" if (++$count % 10000 == 0);

	# read contig coverage file
	my @coverage_vector = (0) x $contigs{$contig}->{length};
	my $ifn = sprintf("%s/%s", $idir, $contig);
	open(IN, $ifn) || die $ifn;
	my $index = 0;
	while (my $line = <IN>) {
	    $coverage_vector[$index++] += $line;
	}
	close(IN);

	# add ref nt where missing
	foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	    my $cov = $coverage_vector[$coord-1];
	    my $ref = $contigs{$contig}->{coords}->{$coord}->{ref};
	    if (!defined($contigs{$contig}->{coords}->{$coord}->{$type})) {
		$contigs{$contig}->{coords}->{$coord}->{$type} = {};
		foreach my $nt (("A", "C", "G", "T")) {
		    $contigs{$contig}->{coords}->{$coord}->{$type}->{$nt} = 0;
		}
		$contigs{$contig}->{coords}->{$coord}->{$type}->{$ref} = $cov;
	    } else {
		my $sum = 0;
		foreach my $nt (("A", "C", "G", "T")) {
		    $sum += $contigs{$contig}->{coords}->{$coord}->{$type}->{$nt};
		}
		($sum == $cov) or die "$type | $contig | $coord : sum=$sum != cov=$cov";
	    }
	}
    }
}

###################################################################################################################
# output merged table
###################################################################################################################

print "writing table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "contig\tcoord\tref";
foreach my $nt (("A", "C", "G", "T")) {
    print OUT "\t", $nt."_base";
}
foreach my $nt (("A", "C", "G", "T")) {
    print OUT "\t", $nt."_set";
}
print OUT "\n";

foreach my $contig (keys %contigs) {
    foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	print OUT "$contig\t$coord\t", $contigs{$contig}->{coords}->{$coord}->{ref};
	foreach my $nt (("A", "C", "G", "T")) {
	    print OUT "\t", $contigs{$contig}->{coords}->{$coord}->{base}->{$nt};
	}
	foreach my $nt (("A", "C", "G", "T")) {
	    print OUT "\t", $contigs{$contig}->{coords}->{$coord}->{set}->{$nt};
	}
	print OUT "\n";
    }
}
close(OUT);

###################################################################################################################
# utils
###################################################################################################################

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
