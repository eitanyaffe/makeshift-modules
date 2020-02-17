#!/usr/bin/env perl

use strict;
use POSIX;
use warnings FATAL => qw(all);
use File::Basename;

if ($#ARGV == -1) {
	print STDERR "usage: $0 <gene table> <GO table> <gene2GO table> >append anchor> <element2anchor table> <fields> <ofn>\n";
	exit 1;
}

my $ifn_genes = $ARGV[0];
my $ifn_GO = $ARGV[1];
my $ifn_gene2GO = $ARGV[2];
my $append_anchor = $ARGV[3];
my $ifn_element2anchor = $ARGV[4];
my $fields_str = $ARGV[5];
my $ofn = $ARGV[6];

my @fields = split(" ", $fields_str);

###############################################################################################
# GO
###############################################################################################

print STDERR "reading table: $ifn_GO\n";
open(IN, $ifn_GO) || die $ifn_GO;
my $header = <IN>;
my %h = parse_header($header);

my %GO;
while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $id = $f[$h{id}];
    $GO{$id} = {};
    foreach my $field (@fields) {
	$GO{$id}->{$field} = {};
    }
}
close(IN);

###############################################################################################
# gene to GO
###############################################################################################

my %genes;
print STDERR "reading table: $ifn_gene2GO\n";
open(IN, $ifn_gene2GO) || die $ifn_gene2GO;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $id = $f[$h{GO}];
    my $gene = $f[$h{gene}];
    $genes{$gene} = {} if (!defined($genes{$gene}));
    $genes{$gene}->{$id} = 1;
}
close(IN);

###############################################################################################
# element2anchor
###############################################################################################

my %elements;
print STDERR "reading table: $ifn_element2anchor\n";
open(IN, $ifn_element2anchor) || die $ifn_element2anchor;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $element = $f[$h{"element.id"}];
    my $anchor = $f[$h{anchor}];
    $elements{$element} = $anchor;
}
close(IN);

###############################################################################################
# genes GO
###############################################################################################

print STDERR "reading table: $ifn_genes\n";
open(IN, $ifn_genes) || die $ifn_genes;
$header = <IN>;
%h = parse_header($header);

while (my $line = <IN>) {
    chomp $line;
    my @f = split("\t", $line);
    my $gene = $f[$h{gene}];

    next if (!defined($genes{$gene}));

    foreach my $id (keys %{$genes{$gene}}) {
	next if (!defined($GO{$id}));
	foreach my $field (@fields) {
	    my $field_value = "";
	    # append the anchor value
	    if ($append_anchor eq "T" && $field eq "anchor") {
		my $element = $f[$h{"element.id"}];
		defined($elements{$element}) or die;
		$field_value = $elements{$element};
	    } else {
		$field_value = $f[$h{$field}];
	    }
	    $GO{$id}->{$field}->{$field_value} = 1;
	}
    }
}
close(IN);

###############################################################################################
# output
###############################################################################################

print STDERR "writing output table: $ofn\n";
open(OUT, ">", $ofn) || die $ofn;
print OUT "GO";
foreach my $field (@fields) {
    print OUT "\t", $field;
}
print OUT "\n";

foreach my $id (keys %GO) {
    print OUT $id;
    foreach my $field (@fields) {
	my $count = scalar(keys %{$GO{$id}->{$field}});
	print OUT "\t", $count;
    }
    print OUT "\n";
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
