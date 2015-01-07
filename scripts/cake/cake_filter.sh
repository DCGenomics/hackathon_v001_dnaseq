#!/bin/bash

#################################
#cake filtering of the multiple calling algrithms result
#this step should be run after cake and mutect calling is done
#varscan bambino somaticsniper is wrapped in cake and muteck is additionally added algrithm
################################

# Make sure we get a 
if [ "A$1" = "A" ]; then
	echo "Please enter sample file!  The output directory will be named based on the filename."
	exit
fi

if [ "A$2" = "A" ]; then
	echo "Please enter an output directory"
	exit
fi

SAMPLEFILE=$1
OUT_DIR=$2

mkdir $OUT_DIR

#launch the perl module in filtering mode
perl /opt/cake/Cake/trunk/scripts/run_somatic_pipeline.pl \
        -s $SAMPLEFILE \
        -species human \
        -callers varscan,bambino,somaticsniper,mutect\
        -separator "," \
        -o $OUT_DIR \
        -mode FILTERING

