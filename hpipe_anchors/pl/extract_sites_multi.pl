#!/usr/bin/env perl

# Example legend:
#  SSSS: cutter site
#  x: any nt
#  +/- location used to mark fragment end
#
# Example 1:
# xx-SSSS+xxxx-SSSS+xxxx
#   |    |    |    |
#   3    8    13   18
#
# fend	frag	strand	chr	coord	frag_len
# 1	1	-	ix	3	3
# 2	2	+	ix	8	6
# 3	2	-	ix	13	6
# 4	3	+	ix	18	5
#
# Example 2:
# xx-SSSSxSSSS+xxxx (frag must be at least 2 nt)
#
# Example 3:
# SSSS+xxx-SSSS (site on end of sequence)


use strict;
use warnings FATAL => qw(all);

my %rc = ("A", "T", "C", "G", "G", "C", "T", "A", "N", "N");

die "Usage: $0 <sequence file> <output> <cutter sites>\n" if $#ARGV < 2;

my $seq_file = $ARGV[0];
my $outfile = $ARGV[1];
shift;shift;
my @sites = @ARGV;

my $site_len = 0;
for (my $i=0; $i<@sites;$i++) {
    my $site = $sites[$i];
    my $site_len_i = length($site);
    if ($i == 0) {
	$site_len = $site_len_i;
    } else {
	$site_len == $site_len_i or die "all cutter sites must be same length";
    }
}

print "sites: ", join(",",@sites), "\n";
print "sequence file: $seq_file\n";
print "output table: $outfile\n";


(int($site_len/2) == $site_len/2) or die "Length of cutter must be even";

my(@hits);

# verify that the site is reverse-symmetric (i.e. the reverse-complement of the site is equal to the site)
foreach my $site (@sites) {
    $site eq get_rc($site) || die "Site must be reverse-symmetric: $site";
}

my $frag_id = 1;
my $ser_id = 1;

open(OUT, ">", $outfile);

# write the header
print OUT "fend\tfrag\tstrand\tcontig\tcoord\tfrag_len\tsite\n";

my $fend = 1;
my $frag = 1;

my %chroms;
my $chrom = "";
my $seq = "";

open(IN, $seq_file) || die $seq_file;
while (my $line = <IN>) {
    chomp($line);
    if (substr($line, 0, 1) eq ">") {
	$chroms{$chrom} = $seq if ($chrom ne "");
	my @f = split(/\s+/, substr($line, 1));
	$chrom = $f[0];
	$seq = "";
    } else {
	$seq .= $line;
    }
}
close(IN);
$chroms{$chrom} = $seq if ($chrom ne "");

my $skip_count = 0;

foreach my $chrom (keys %chroms) {
    my $seq = $chroms{$chrom};

    my $length = length($seq);
    my $coord = 0;
    my $next_coord = -1;
    my $site = "";

    foreach my $site_i (@sites) {
	my $next_coord_i = index($seq, $site_i);
	if ($next_coord_i != -1 && ($next_coord == -1 || $next_coord_i < $next_coord)) {
	    $next_coord = $next_coord_i;
	    $site = $site_i;
	}
    }

    # site not found at all
    if ($next_coord == -1) {
	$skip_count++;
	# print "Skipping $chrom, no sites found\n";
	next;
    }

    # first fragment has only a right fend, if first site not on start of sequence
    if ($next_coord != 0) {
	add_fend($frag, $fend, $site_len, 0, $next_coord, $chrom, "-", $site);
	$fend += 1;
	$frag += 1;
    }

    my $prev_site = $site;

    # middle fragments have two ends each
    while (1) {
	$coord = $next_coord;

	$next_coord = -1;
	foreach my $site_i (@sites) {
	    my $next_coord_i = index($seq, $site_i, $coord + $site_len);
	    if ($next_coord_i != -1 && ($next_coord == -1 || $next_coord_i < $next_coord)) {
		$next_coord = $next_coord_i;
		$site = $site_i;
	    }
	}
	last if ($next_coord == -1);

	# add if fragment only if length is >1
	if ($coord+$site_len+1 < $next_coord) {
	    add_fend($frag, $fend, $site_len, $coord+$site_len+1, $next_coord+1, $chrom, "+", $prev_site);
	    add_fend($frag, $fend+1, $site_len, $coord+$site_len, $next_coord, $chrom, "-", $site);
	    $frag += 1;
	    $fend += 2;
	}
	$prev_site = $site;
    }

    # last fragment has only a left fend, if last site not on end of sequence
    if (($coord+$site_len) != $length) {
	add_fend($frag, $fend, $site_len, $coord+1+$site_len, $length+1, $chrom, "+", $site) ;
	$frag += 1;
	$fend += 1;
    }
}
close(OUT);

print "number of contigs: ", scalar(keys %chroms), "\n";
print "contigs lacking site: ", $skip_count, "\n";

# returns reverse-complement of the argument
sub get_rc {
    my ($str) = @_;
    my $len = length($str);
    my $rcstr = "";
    for (my($i) = $len - 1; $i >= 0; $i--) {
	$rcstr .= $rc{substr($str, $i, 1)};
    }
    return($rcstr);
}

sub add_fend {
    my ($frag, $fend, $site_len, $coord, $next_coord, $chrom, $strand, $site) = @_;
    my $frag_len = $next_coord - $coord;

    if ($strand eq "+") {
	print OUT "$fend\t$frag\t$strand\t$chrom\t$coord\t$frag_len\t$site\n";
    } else {
	print OUT "$fend\t$frag\t$strand\t$chrom\t$next_coord\t$frag_len\t$site\n";
    }
}
