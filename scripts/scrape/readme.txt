Scripts:

scrape.sh
    This script is a hack of a web-scraper to grab files from the
    SRA website.  Using 'prefetch' would likely be better, but it requires
    somewhat troublesome configuration to not fill /home or /
    partitions (and thus break the systems).  This script has more
    control over where the output files are written.

convert.sh
    This is a simple wrapper around:
        sam-dump $SRAFILE | awk '{...}' | samtools view -bS - > $BAMFILE
    
    While trivial, wrapping these commands in small script/function
    makes parallization more easy.  

    This script does three things:
        1) converts from SRA to SAM format
        2) removes lines that cause samtools to coredump (reads 
           where the sequence length != quality score length)
        3) converts to BAM


