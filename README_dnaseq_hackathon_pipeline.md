dnaseq_hackathon_pipeline.sh
============================

dnaseq_hackathon_pipeline.sh is designed to process human DNA-Seq data (such as exome sequencing). Specifically, it compares tumor vs. normal samples, outputs VCF files of variants unique to tumor samples. It is built around Cake (somatic.sourceforge.net), and provides additional functionality and analysis by incorporating other bioinformatics tools into the pipeline. 

This pipeline was written during the NCBI/ADDS NIH Hackathon, and should currently be considered a work in progress.

Requirements
------------

dnaseq_hackathon_pipeline.sh is designed to run on Linux, specifically an AWS instance. It can also run on OS X, but please be aware that it wasn't primarily intended to do so.

The following programs must be present on your system, and preferably should be in a directory in your $PATH. It is recommended that the version is at least as recent as those listed here:
* cake v1.0, including all dependencies
* picard v1.127
* annovar
* bambino
* somatic_sniper v1.0.4
* muTect v1.1.5
* varscan v2.3.7
* samtools v1.1
* GNU Parallel
* vcftools v.0.1.5
* tabix v.0.2.5
* bgzip

In addition, while not required for the Bash version of the pipeline, the following are required for the bpipe pipeline:
* bpipe v0.9.8.6_rc2


Usage
-------

	dnaseq_hackathon_pipeline.sh NORMAL_IN TUMOR_DIR_IN GFF ACCESSION MUTECT_JAR REFERENCE_FASTA COSMIC_VCF DBSNP_VCF INTERVALS

The input files are as follows:

NORMAL_IN: An aligned BAM file of human DNA-Seq data for the normal control.
	
TUMOR_DIR_IN: A directory that contains the aligned BAMs of human DNA-Seq tumor data.

GFF: A GFF file of human genome features.

ACCESSION: A two-column text file with chromosome number in the first column, and the corresponding NCBI accession ID in the second. The `reference/Accession2chr.txt` file can be used for GRCh37.

MUTECT_JAR: The location of the muTect .jar file.

REFERENCE_FASTA: A FASTA file of the reference to which the BAMs were aligned.

COSMIC_VCF: A VCF file containing variants from COSMIC.

DBSNP_VCF: A VCF file containing variants from dbSNP.

INTERVALS: An interval file for muTect.

	
The input files don't need to be in the same directory as the script; relative or absolute paths can be provided for any of the inputs.


There are additional programs that may be useful for post-hoc analysis, but which have not yet been integrated into the pipeline. Some of these are outlined in the comments in the script itself. For example, to identify variants shared by and unique to two VCF files, users can run:

	scripts/vcf_venn.sh ${VCF_1} ${VCF_2}



Output
-------

The output is placed in a directory called `Output_dnaseq_${ID}`. 

* cake_mutect_merged/: The primary output, this directory contains the consensus variants identified by muTect and the algorithms called by Cake. 

* mutect_text/: A directory containing various data about the muTect run.


License
-------

dnaseq_hackathon_pipeline.sh is licensed under CC0 1.0 Universal.


Contact
-------

Matthew C. LaFave, Ph.D.,
Developmental Genomics Section, Translational and Functional Genomics Branch,
NHGRI, NIH

Email: matthew.lafave [at sign] nih.gov
