#! /usr/bin/perl 

### Manjusha Pande, mpande@umich.edu, 01/06/15
### Getting exon positions from NCBI b37 gff file
### usage: perl gtf2pos.pl <input.gtf> 
### This script needs a text file "Accession2chr.txt" to get chromosome number from NCBI chromosome accession number
### Example:  perl gtf2pos.pl /blast-c/hg19_resource_files/ref_GRCh37.p5_top_level.gff3
#########################################################################################################################
use strict;
use warnings;
use Data::Dumper;

my $inFile = $ARGV[0];
my $accessionFile = "../reference/Accession2chr.txt";
my $outFile = "b37_exon_positions.txt";

my %accession2chr = ();
open (INIFILE1, "<".$accessionFile) or die "Cannot open $accessionFile $!\n";
while (<INIFILE1>) {
	my $line = $_;
	chomp $line;
	my @tmp = split(/\t/, $line) ;
	$accession2chr{$tmp[1]}= $tmp[0];
}
#print Dumper %accession2chr;
close INIFILE1;

open (INIFILE2, "<".$inFile) or die "Cannot open $inFile $!\n";
my @pos = ();
while (<INIFILE2>) {
	my $line = $_;
	chomp $line;
	if ($line =~ /exon/) {
		#print "$_\n";
		my @tmp = split(/\s+/, $line) ;
		#print "$tmp[2]\n";
		my $chr;
		if (exists ($accession2chr{$tmp[0]})) {
			$chr = $accession2chr{$tmp[0]};
			#print "\$tmp[0] is $tmp[0], chr is $chr\n";
			push(@pos, $chr, ":", $tmp[3], "-", $tmp[4], "\n");
		}
	}
}
close INIFILE2;
open (OUTFILE, ">".$outFile) or die "Cannot open $outFile $!\n";

#print Dumper @pos;
for my $a (0..$#pos) {
	print OUTFILE $pos[$a];
}

