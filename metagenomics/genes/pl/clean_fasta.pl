#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

while (my $line = <STDIN>) {
    if (substr($line, 0, 1) eq ">") {
	chomp($line);
	my @f1 = split("#",$line);
	my @f2 = split(";",$f1[4]);
	my @f3 = split("=",$f2[0]);
	my $gene = "g".$f3[1];
	print ">", $gene, "\n";
    } else {
	print $line;
    }
}
