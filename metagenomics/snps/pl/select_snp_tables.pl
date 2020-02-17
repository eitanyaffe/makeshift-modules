#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <contig table> <selected position table> <idir> <only fixed T|F> <out prefix> <id1 id2 ...>\n";
	exit 1;
}

my $ifn_contigs = $ARGV[0];
my $ifn_pos = $ARGV[1];
my $idir = $ARGV[2];
my $only_fixed = $ARGV[3] eq "T";
my $prefix = $ARGV[4];
shift; shift; shift; shift; shift;
my @ids = @ARGV;

# print "processing ids: ", join(",", @ids), "\n";


###################################################################################################################
# load selected position table
###################################################################################################################

my %contigs;

print "reading position table: $ifn_pos\n";
open(IN, $ifn_pos) || die $ifn_pos;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $coord = $f[$h{coord}];
    my $fix = $f[$h{fix}] eq "T";

    next if ($only_fixed && !$fix);

    # next if ($contig ne "k147_58883:s1");

    if (!defined($contigs{$contig})) {
	$contigs{$contig} = {};
	$contigs{$contig}->{coords} = {};
    }

    $contigs{$contig}->{coords}->{$coord} = {};
    $contigs{$contig}->{coords}->{$coord}->{ids} = {};
}
close(IN);

###################################################################################################################
# add length from contig table
###################################################################################################################

print "reading contig table: $ifn_contigs\n";
open(IN, $ifn_contigs) || die $ifn_contigs;
$header = <IN>;
%h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $length = $f[$h{length}];
    next if (!defined($contigs{$contig}));
    $contigs{$contig}->{length} = $length;
}
close(IN);

###################################################################################################################
# go over snp tables
###################################################################################################################

my @nts = ("A", "C", "G", "T");
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

	next if (!defined($contigs{$contig}) || !defined($contigs{$contig}->{coords}->{$coord}));
	$contigs{$contig}->{coords}->{$coord}->{ref} = $ref if (!defined($contigs{$contig}->{coords}->{$coord}->{ref}));
	$contigs{$contig}->{coords}->{$coord}->{ids}->{$id} = [0,0,0,0];
	for (my $i=0; $i<4; $i++) {
	    my $nt = $nts[$i];
	    $contigs{$contig}->{coords}->{$coord}->{ids}->{$id}[$i] = $f[$h{$nt}];
	}
	$contigs{$contig}->{coords}->{$coord}->{found} = 1;
    }
    close(IN);
}

###################################################################################################################
# verify all coords were found
###################################################################################################################

my $count = 0;
my $skipped = 0;
foreach my $contig (keys %contigs) {
    foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	$count++;
	if (!defined($contigs{$contig}->{coords}->{$coord}->{found})) {
	    $skipped++;
	    delete($contigs{$contig}->{coords}->{$coord});
	}
    }
}
print "total selected positions: $count\n";
print "number of positions skipped since no snp data was available: $skipped\n";

###################################################################################################################
# append ref coverage where data was missing
###################################################################################################################

print "appending coverage values where values are missing, number of contigs: ", scalar keys %contigs, "\n";
foreach my $id (@ids) {
    my $count = 0;
    print "processing id: $id\n";
    foreach my $contig (keys %contigs) {
	print "progress: ",$count, " contigs\n" if (++$count % 10000 == 0);

	# read contig coverage file
	my @coverage_vector = (0) x $contigs{$contig}->{length};

	# try direct file first, then tar archive
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
	    $contigs{$contig}->{coords}->{$coord}->{ids}->{$id} = [0,0,0,0];
	    for (my $i=0; $i<4; $i++) {
		my $nt = $nts[$i];
		$contigs{$contig}->{coords}->{$coord}->{ids}->{$id}[$i] = ($ref eq $nt) ? $cov : 0;
	    }
	}
    }
}

###################################################################################################################
# save result in separate tables
###################################################################################################################

for (my $i=0; $i<5; $i++) {
    my $ofn = ($i < 4) ? $prefix.".".$nts[$i] : $prefix.".total";
    print "writing output table: $ofn\n";
    open(OUT, ">", $ofn);
    print OUT "contig\tcoord";
    foreach my $id (@ids) {
	print OUT "\t", $id;
    }
    print OUT "\n";

    foreach my $contig (keys %contigs) {
	foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	    print OUT $contig, "\t", $coord;
	    foreach my $id (@ids) {
		defined ($contigs{$contig}->{coords}->{$coord}->{ids}->{$id}) or die;
		my $count = 0;
		if ($i < 4) {
		    $count = $contigs{$contig}->{coords}->{$coord}->{ids}->{$id}[$i];
		} else {
		    for (my $j=0; $j<4; $j++) {
			$count += $contigs{$contig}->{coords}->{$coord}->{ids}->{$id}[$j];
		    }
		}
		print OUT "\t", $count;
	    }
	    print OUT "\n";
	}
    }
    close(OUT);
}

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
