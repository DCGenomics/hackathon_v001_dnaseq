#!/usr/bin/env bash

# Set up functions for file testing & error reporting.
function throw_error
{
	echo >&2 ERROR: $1
	exit 1
}

function test_file
{
	if 
		[ -s $1 ]
	then 
		echo "$1 detected."
	else  
		throw_error "There is no data-containing file named ${1}"
	fi
}

function full_path ()
{
	DIR=`dirname $1`
	FILE=`basename $1`
	PATH="`cd \"$DIR\" 2>/dev/null && pwd -P || echo \"$DIR\"`/$FILE"
	echo $PATH
}

# Requirements:
# perl
# python (and pylab, pysam, numpy)
# Everything Cake needs
# vcftools
# tabix
# bgzip
# java (at least version 7)
# etc.



NORMAL_IN=$1
TUMOR_DIR_IN=$2
GFF_PATH=`full_path $3`
ACCESSION_PATH=`full_path $4`
MUTECT_JAR_PATH=`full_path $5`
REFERNCE_FASTA_PATH=`full_path $6`
COSMIC_VCF_PATH=`full_path $7`
DBSNP_VCF_PATH=`full_path $8`
INTERVALS_PATH=`full_path $9`


NORMAL_FILE=`basename $NORMAL_IN`
NORMAL_PATH=`full_path $NORMAL_IN`


TUMOR_DIR=`basename $TUMOR_DIR_IN`
TUMOR_DIR_PATH=`full_path $TUMOR_DIR_IN`



# Make working directory

ID=`date +"%s"`

WORKDIR=$PWD/Workdir_DNAseqpipeline_${ID}

mkdir $WORKDIR
cd $WORKDIR



# Start here, with the assumption that the user has valid, local BAMs.


# Look at the quality, etc., of the BAM files.

# Requires pylab, pysam, numpy

# BAM_BaseQual_Flags_FL.py 



# bam_reorder.sh (wenluo711) could go here, but since it's hard-coded to a
# specific human genome release, it isn't generalizable.



# gtf2pos.pl (mpande14) outputs a text file of exon positions, as converted
# from the NCBI b37 gff. Presumably this will work for any GFF. Needs
# Accession2chr.txt location submitted with it (or another accession file for
# whatever the user plans to compare to).

echo "Identifying exon positions..."
perl ../scripts/gtf2pos_forShell.pl ${GFF_PATH} ${ACCESSION_PATH}

test_file exon_positions.txt


# Make the header for the cake CSV file
echo "SampleID,NormalID,Cohort,PatientID,Type,TumorBAM,NormalBAM" > cake_sample.csv


# (MuTect variant calling)

# Make directories in which to put the various mutect outputs

mkdir java_temp
mkdir mutect_text


for i in `ls ${TUMOR_DIR_PATH}`
do
	
	echo ""
	echo "Running mutect for ${i}..."
	../scripts/mutect_t_vs_n.sh \
		$MUTECT_JAR_PATH \
		$REFERNCE_FASTA_PATH \
		$COSMIC_VCF_PATH \
		$DBSNP_VCF_PATH \
		$INTERVALS_PATH \
		$NORMAL_PATH \
		${TUMOR_DIR_PATH}/${i}

	test_file ${TUMOR_BAM}_vs_${NORMAL_BAM}_mutect.vcf

	# As long as this loop is here, may as well make the .csv file that cake
	# will need

	awk -v sampleID="${i}" tumorBAM="${TUMOR_DIR_PATH}/${i}" normalBAM="${NORMAL_PATH}" '{print sampleID",control,TvN,P1,Tumoral,"tumorBAM","normalBAM}' >> cake_sample.csv

done

rm -r java_temp/

# Ends with mutect_text full of log files, and the relevant vcfs in the main directory.


# (cake variant calling)

# Remember, the path to mutect needs to be specified in the
# SomaticCallerConfig.pm file.

echo ""
echo "Running cake variant calling..."
../cake_calling.sh cake_sample.csv

# Output goes to cake_sample.csv_dir.
# Need to put the mutect output into that directory before filtering.

mv *.vcf cake_sample.csv_dir/

# perl_cake_filter.sh (wenluo711) should be run after cake and mutect calling
# is done. It calls cake to parse the results of the various variant callers.
# Takes a CSV input; output is VCF.


#perl_cake_filter.sh ${CSVFILE} ${OUT_DIR}

mkdir cake_mutect_merged

echo ""
echo "Running cake filter to integrate mutect..."
../cake_filter.sh cake_sample.csv cake_mutect_merged/


# (Any annovar analysis can go here)



# ACMG_intersect (simpsoncl) - identifies hits overlapping the ACMG list of
# reportable genes.

# awk '{print $1"\t"$2"\t"$3}' ${ANNOVAR_OUTPUT} \
# 	| intersectBed -wa -a ACMG_gene_list.bed -b - \
# 	> ACMG_hits.bed



# vcf_venn.sh (mlafave) creates an output directory in which gzipped VCF files
# indicate the variants unique to, and shared by, two VCF files.
# It's currently difficult to cleanly integrate into this script because the
# number of VCFs to compare is unknown, but it can be called as:

#vcf_venn.sh ${VCF_1} ${VCF_2}


# Create output directory
mkdir Output_dnaseq_${ID}

mv mutect_text/ Output_dnaseq_${ID}/
mv cake_mutect_merged/ Output_dnaseq_${ID}/
#mv ACMG_hits.bed Output_dnaseq_${ID}/


# Move output directory out of the working directory

echo ""
echo "Moving the Output directory..."
if 
  [ -e ../Output_dnaseq_${ID}]
then 
  throw_error "Can't move Output_dnaseq_${ID}; a file with that name already exists in parent directory!"
else  
  mv Output_dnaseq_${ID}/ .. || throw_error "Didn't move Output_dnaseq_${ID}!"
fi 

cd ..
rm -r $WORKDIR



echo ""
echo ""
echo "dnaseq_pipeline.sh finished!"
exit 0
