#!/bin/bash


OUTDIR=/blast-c/sra_data/meningioma/bam
SAMDUMP=/usr/bin/sratoolkit.2.4.2-ubuntu64/bin/sam-dump
SRA_DATA=/blast-c/sra_data/meningioma/sra
SAMTOOLS=/usr/bin/samtools

IFILE=$SRA_DATA/$1
OFILE=$OUTDIR/${1/.*/}.sam

if [ -e $IFILE -a ! -e $OFILE ]; then

	echo "$SAMDUMP $IFILE | awk '{ if( length($10) == length($11)) { print } }' | $SAMTOOLS view -bS - > $OFILE"
              $SAMDUMP $IFILE | awk '{ if( length($10) == length($11)) { print } }' | $SAMTOOLS view -bS - > $OFILE
#	echo "$SRADUMP $IFILE > $OFILE"
#	      $SRADUMP $IFILE > $OFILE
else
	if [ ! -e $IFILE ]; then
		echo "Missing input file!  Skipping"
		echo "IN: $IFILE"
	fi
	if [ -e $OFILE ]; then
		echo "Output file exists!  Skipping"
		echo "OUT: $OFILE"
	fi
fi
