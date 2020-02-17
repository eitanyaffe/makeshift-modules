#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <contig table> <idir> <ofn> <id1 id2 ...>\n";
	exit 1;
}

my $ifn_contigs = $ARGV[0];
my $idir = $ARGV[1];
my $ofn = $ARGV[2];
shift; shift; shift;
my @ids = @ARGV;

# print "processing ids: ", join(",", @ids), "\n";

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
# go over snp tables
###################################################################################################################

my $hheader;
foreach my $id (@ids) {
    my $ifn = sprintf("%s/%s/vari/out_snp_full.tab", $idir, $id);
    print "reading table: $ifn\n";
    open(IN, $ifn) || die $ifn;
    my $header = <IN>;
    $hheader = $header;
    my %h = parse_header($header);
    while (my $line = <IN>) {
	chomp($line);
	my @f = split("\t", $line);
	my $contig = $f[$h{contig}];
	my $coord = $f[$h{coord}];
	my $ref = $f[$h{ref}];

	$contigs{$contig} = {} if (!defined($contigs{$contig}));
	if (!defined($contigs{$contig}->{coords}->{$coord})) {
	    $contigs{$contig}->{coords}->{$coord} = {};
	    $contigs{$contig}->{coords}->{$coord}->{ref} = $ref;
	    $contigs{$contig}->{coords}->{$coord}->{A} = 0;
	    $contigs{$contig}->{coords}->{$coord}->{C} = 0;
	    $contigs{$contig}->{coords}->{$coord}->{G} = 0;
	    $contigs{$contig}->{coords}->{$coord}->{T} = 0;
	    $contigs{$contig}->{coords}->{$coord}->{ids} = {};
	}
	foreach my $nt (("A", "C", "G", "T")) {
	    $contigs{$contig}->{coords}->{$coord}->{$nt} += $f[$h{$nt}];
	}
	$contigs{$contig}->{coords}->{$coord}->{ids}->{$id} = 1;
    }
    close(IN);
}

###################################################################################################################
# append ref coverage where data was missing
###################################################################################################################

foreach my $id (@ids) {
    my $count = 0;
    print "appending for id $id contig coverages where values are missing, number of contigs: ", scalar keys %contigs, "\n";
    foreach my $contig (keys %contigs) {
	print "progress: ",$count, " contigs\n" if (++$count % 10000 == 0);

	# read contig coverage file
	my @coverage_vector = (0) x $contigs{$contig}->{length};

	my $ifn = sprintf("%s/%s/vari/output_full/%s.cov", $idir, $id, $contig);
	if (-e $ifn) {
	    open(IN, $ifn) || die $ifn;
	} else {
	    my $tar_fn = sprintf("%s/%s/vari/output_full.tar", $idir, $id);
	    open(IN, "-|", sprintf("tar xf %s -O ./%s.cov", $tar_fn, $contig)) || die "failed to retrieve file for contig $contig from archive $tar_fn";
	}
	my $index = 0;
	while (my $line = <IN>) {
	    $coverage_vector[$index++] += $line;
	}
	close(IN);

	foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	    next if (defined($contigs{$contig}->{coords}->{$coord}->{ids}->{$id}));
	    my $cov = $coverage_vector[$coord-1];
	    my $ref = $contigs{$contig}->{coords}->{$coord}->{ref};
	    $contigs{$contig}->{coords}->{$coord}->{$ref} += $cov;
	}
    }
}

###################################################################################################################
# save result
###################################################################################################################

print "writing file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT $hheader;
foreach my $contig (keys %contigs) {
    foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	print OUT $contig, "\t", $coord, "\t";
	print OUT $contigs{$contig}->{coords}->{$coord}->{A}, "\t", $contigs{$contig}->{coords}->{$coord}->{C}, "\t", $contigs{$contig}->{coords}->{$coord}->{G}, "\t", $contigs{$contig}->{coords}->{$coord}->{T};
	print OUT "\t", $contigs{$contig}->{coords}->{$coord}->{ref}, "\n";
    }
}
close(OUT);

#######################################################################################
# utils
#######################################################################################

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
