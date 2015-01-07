#!/usr/bin/perl
use warnings;
use strict;

#################################
### This is a spcript to add  ###
### the line number to annovar ##
### format list of variants  ####
################################

my $in = shift @ARGV;
open(IN, '<', $in) or die "the file doesn't exist";
my $i=1;

while (my $line = <IN>) {
                chomp $line;
                if($line=~/./){
                print "$line\tline$i\n";
                $i++;
                }
                
}
