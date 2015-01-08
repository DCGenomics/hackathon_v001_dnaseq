#!/bin/bash 

# Make sure we get a 
if [ "A$1" = "A" ]; then
	echo "Please enter sample file!  The output directory will be named based on the filename."
	exit
fi

SAMPLEFILE=$1

OUT_DIR=`basename ${SAMPLEFILE}`
OUT_DIR=`echo $OUT_DIR | sed 's/\..*//'`


mkdir ${OUT_DIR}_dir

perl /opt/cake/Cake/trunk/scripts/run_somatic_pipeline.pl \
	-s $SAMPLEFILE \
	-species human \
	-callers mpileup,varscan,bambino,somaticsniper \
	-separator "," \
	-o ${OUT_DIR}_dir \
	-mode CALLING





