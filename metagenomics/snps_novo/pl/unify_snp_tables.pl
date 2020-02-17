#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

if ($#ARGV == -1) {
	print STDERR "usage: $0 <contig table> <idir> <ofn> <id1 id2 ...>\n";
	exit 1;
}

my $ifn_contigs = $ARGV[0];
my $idir = $ARGV[1];
my $prefix = $ARGV[2];
shift; shift; shift;
my @ids = @ARGV;

# print "processing ids: ", join(",", @ids), "\n";

###################################################################################################################
# load contig table
###################################################################################################################

my %contigs;

print "reading contig table: $ifn_contigs\n";
open(IN, $ifn_contigs) || die $ifn_contigs;
my $header = <IN>;
my %h = parse_header($header);
while (my $line = <IN>) {
    chomp($line);
    my @f = split("\t", $line);
    my $contig = $f[$h{contig}];
    my $length = $f[$h{length}];

    # next if ($contig ne "k147_57916:s2");

    $contigs{$contig} = {};
    $contigs{$contig}->{length} = $length;
    $contigs{$contig}->{coords} = {};
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

	next if (!defined($contigs{$contig}));
	if (!defined($contigs{$contig}->{coords}->{$coord})) {
	    $contigs{$contig}->{coords}->{$coord} = {};
	    $contigs{$contig}->{coords}->{$coord}->{ref} = $ref;
	    $contigs{$contig}->{coords}->{$coord}->{ids} = {};
	}
	$contigs{$contig}->{coords}->{$coord}->{ids}->{$id} = [0,0,0,0];
	for (my $i=0; $i<4; $i++) {
	    my $nt = $nts[$i];
	    $contigs{$contig}->{coords}->{$coord}->{ids}->{$id}[$i] = $f[$h{$nt}];
	}
    }
    close(IN);
}

###################################################################################################################
# remove coords if only one nt is supported by over 1 reads across all libs
###################################################################################################################

print "removing coords if only one nt is supported by over 1 reads across all libs\n";
my $count_r = 0;
foreach my $contig (keys %contigs) {
    foreach my $coord (sort {$a <=> $b} keys %{$contigs{$contig}->{coords}}) {
	my %nt_covered;
	foreach my $id (@ids) {
 	    next if (!defined($contigs{$contig}->{coords}->{$coord}->{ids}->{$id}));
	    for (my $i=0; $i<4; $i++) {
		$nt_covered{$i} = 1 if ($contigs{$contig}->{coords}->{$coord}->{ids}->{$id}[$i] > 1);
	    }
	}
	if (scalar(keys %nt_covered) <= 1) {
	    delete($contigs{$contig}->{coords}->{$coord});
	    $count_r++;
	}
    }
}
print sprintf("number of removed coords: %d\n", $count_r);


###################################################################################################################
# append ref coverage where data was missing
###################################################################################################################

print "appending coverage values\n";
foreach my $id (@ids) {
    my $count = 0;
    print "appending for id $id contig coverages where values are missing, number of contigs: ", scalar keys %contigs, "\n";
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
