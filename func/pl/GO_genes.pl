#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <gene table> <GO table> <ofn>\n";
	exit 1;
}

my $ifn_genes = $ARGV[0];
my $ifn_go = $ARGV[1];
my $ofn = $ARGV[2];

###############################################################################################
# read categories
###############################################################################################

my %gos;

print STDERR "reading table: $ifn_go\n";
open(IN, $ifn_go) || die $ifn_go;
my $header = <IN>;
my %h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $id = $f[$h{id}];
    $gos{$id} = {};
    $gos{$id}->{type} = $f[$h{type}];
    $gos{$id}->{desc} = $f[$h{desc}];
    $gos{$id}->{count} = $f[$h{count}];
    $gos{$id}->{genes} = {};
}
close(IN);

###############################################################################################
# read genes
###############################################################################################

print STDERR "reading table: $ifn_genes\n";
open(IN, $ifn_genes) || die $ifn_genes;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];
    my $id = $f[$h{GO}];

    next if (!defined($gos{$id}));

    $gos{$id}->{genes}->{$gene} = {};
    $gos{$id}->{genes}->{$gene}->{uniref} = $f[$h{uniref}];
    $gos{$id}->{genes}->{$gene}->{gene_desc} = $f[$h{prot_desc}];
}
close(IN);

###############################################################################################
# output
###############################################################################################

print STDERR "generating file: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "type\tid\tdesc\tgene\tuniref\tgene_desc\n";

for my $id (keys %gos) {
    my $type = $gos{$id}->{type};
    my $desc = $gos{$id}->{desc};
    my $count = $gos{$id}->{count};

    my @genes = keys %{$gos{$id}->{genes}};
    for my $gene (@genes) {
	my $uniref = $gos{$id}->{genes}->{$gene}->{uniref};
	my $gene_desc = $gos{$id}->{genes}->{$gene}->{gene_desc};
	print OUT $type, "\t", $id, "\t", $desc, "\t", $gene, "\t", $uniref, "\t", $gene_desc, "\n";
    }
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
