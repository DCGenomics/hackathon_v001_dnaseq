#!/usr/bin/env bash



MUTECT_JAR_PATH=$1
REFERNCE_FASTA_PATH=$2
COSMIC_VCF_PATH=$3
DBSNP_VCF_PATH=$4
INTERVALS_PATH=$5
NORMAL_BAM=$6
TUMOR_BAM=$7


nohup java -Xmx8g \
	-Djava.io.tmpdir=java_temp \
	-jar ${MUTECT_JAR_PATH} \
	--analysis_type MuTect \
	-rf BadCigar \
	--reference_sequence ${REFERNCE_FASTA_PATH} \
	--cosmic ${COSMIC_VCF_PATH} \
	--dbsnp ${DBSNP_VCF_PATH} \
	--intervals ${INTERVALS_PATH} \
	--input_file:normal ${NORMAL_BAM} \
	--input_file:tumor ${TUMOR_BAM} \
	--out mutect_text/${TUMOR_BAM}_vs_${NORMAL_BAM}_mutect_call_stats.txt \
	--coverage_file mutect_text/${TUMOR_BAM}_vs_${NORMAL_BAM}_mutect_coverage.txt \
	--vcf ${TUMOR_BAM}_vs_${NORMAL_BAM}_mutect.vcf \
	2>&1 \
	> mutect_text/${TUMOR_BAM}_vs_${NORMAL_BAM}_mutect.log

exit 0
