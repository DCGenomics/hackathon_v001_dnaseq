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



# Input: Two VCF files, which contain single nucelotide variants that are
# present in tumor samples & not in normal germline samples. For instance, one
# sample may be the primary tumor, and the other a metastatic sample.

# Read in files

VCF_1=$1
VCF_2=$2

test_file $VCF_1
test_file $VCF_2



# Check for vcftools, bgzip and tabix (unless the .tbi file is already there, I
# suppose)

hash vcf-isec 2>/dev/null || throw_error "vcf-isec not found"
hash vcf-sort 2>/dev/null || throw_error "vcf-sort not found"
hash bgzip 2>/dev/null || throw_error "bgzip not found"
hash tabix 2>/dev/null || throw_error "tabix not found"



# Identify full paths to the inputs

DIR_1=`dirname $VCF_1`
FILE_1=`basename $VCF_1`
PATH_1="`cd \"$DIR_1\" 2>/dev/null && pwd -P || echo \"$DIR_1\"`/$FILE_1"

DIR_2=`dirname $VCF_2`
FILE_2=`basename $VCF_2`
PATH_2="`cd \"$DIR_2\" 2>/dev/null && pwd -P || echo \"$DIR_2\"`/$FILE_2"



# Create a working directory

# ID is time since epoch

ID=`date +"%s"`

WORKDIR=$PWD/Workdir_venn_${ID}

mkdir $WORKDIR
cd $WORKDIR



# For each VCF, compress with bgzip. Sort first just to be sure.

echo ""
echo "Sorting and compressing VCFs..."

vcf-sort $PATH_1 | bgzip -c > ${VCF_1}.gz
vcf-sort $PATH_2 | bgzip -c > ${VCF_2}.gz

test_file ${VCF_1}.gz
test_file ${VCF_2}.gz



# Generate .tbi file with tabix

echo ""
echo "Generating .tbi files..."

tabix -p vcf ${VCF_1}.gz
tabix -p vcf ${VCF_2}.gz

test_file ${VCF_1}.gz.tbi
test_file ${VCF_2}.gz.tbi



# Use vcf-isec -p to create files for those unique to each file, and a third
# file for those that appear in both (which we can probably just delete)

echo ""
echo "Taking intersection..."

vcf-isec -p venn ${VCF_1}.gz ${VCF_2}.gz

test_file venn0.vcf.gz
test_file venn1.vcf.gz
test_file venn0_1.vcf.gz

if [ -f venn_README ] ; then rm venn_README ; fi

rm ${VCF_1}.gz
rm ${VCF_2}.gz

rm ${VCF_1}.gz.tbi
rm ${VCF_2}.gz.tbi




# Put files in Output directory & rename

echo ""
echo "Moving and renaming files in the Output directory..."

mkdir $PWD/Output_vcf_venn_${ID}

mv venn0.vcf.gz Output_vcf_venn_${ID}/unique_in_${1}_NOT_in_${2}.gz
mv venn1.vcf.gz Output_vcf_venn_${ID}/unique_in_${2}_NOT_in_${1}.gz
mv venn0_1.vcf.gz Output_vcf_venn_${ID}/shared_by_${1}_AND_${2}.gz


# Move output directory out of the working directory & remove working directory

echo ""
echo "Moving the Output directory..."
if 
  [ -e ../Output_vcf_venn_${ID} ]
then 
  throw_error "Can't move Output_vcf_venn_${ID}; a file with that name already exists in parent directory!"
else  
  mv Output_vcf_venn_${ID}/ .. || throw_error "Didn't move Output_vcf_venn_${ID}!"
fi 

cd ..
rm -r $WORKDIR



echo ""
echo "$0 finished."

exit
