#$!/Bin/sh

BASEURL="http://www.ncbi.nlm.nih.gov/sra?term=DRP000442"
DOWNLOAD=0

HTML="newlines.html"

#curl $BASEURL | perl -pe 's/<span/\n<span/g' > $HTML

mkdir -p HTML_FILES

# download webpages.
if [ "$DOWNLOAD" = 1 ] ; then
for URL in `pcregrep -o 'http://www.ncbi.nlm.nih.gov/sra/D[^"]+' $HTML`; do
	# Extract Accession number
	ACC=`echo $URL | pcregrep -o 'D[A-Z0-9]+' `

	echo $ACC | tee ACC.txt

	if [ ! -e "HTML_FILES/$ACC" ]; then
		curl -sS --globoff "$URL" > HTML_FILES/$ACC 
	fi
done 

fi


#For each accession number, find the FTP URL, and download it
mkdir -p SRA_DATA
for F in HTML_FILES/*; do 
	FTP=`pcregrep -o 'ftp://\S+/DRR\d+?[^"]+' $F`
	ACC=`echo $FTP | sed 's,.*/,,'`
	FTP="$FTP/$ACC.sra"
	printf "%s %s\n" $F $ACC
	( cd SRA_DATA; wget -c $FTP )

done


