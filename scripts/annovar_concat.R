coutput<-commandArgs(trailingOnly=TRUE)
read.delim(file="example_refseq_genes.exonic_variant_function", sep="\t", header=FALSE)
colnames(ex)<-c("newline","effect","exon","chr","start","end","ref","alt","line")
all<-read.delim(file="example_refseq_genes.variant_function", sep="\t", header=FALSE)
colnames(all)<-c("location","gene","chr","start","end","ref","alt","line")
exk<-read.delim(file="example_known_genes.exonic_variant_function", sep="\t", header=FALSE)
colnames(exk)<-c("newlinek","effectk","exonk","chr","start","end","ref","alt","line")
allk<-read.delim(file="example_known_genes.variant_function", sep="\t", header=FALSE)
colnames(allk)<-c("locationk","genek","chr","start","end","ref","alt","line")
clinvar<-read.delim(file="example_clinvar.hg19_clinvar_20140929_dropped", sep="\t", header=FALSE)
colnames(clinvar)<-c("clinvarDB","CLNann","chr","start","end","ref","alt","line")
cadd<-read.delim(file="example_cadd.hg19_caddgt20_dropped", sep="\t", header=FALSE)
colnames(cadd)<-c("CADD_DB","CADD_score","chr","start","end","ref","alt","line")
cosmic<-read.delim(file="example_cosmic.hg19_cosmic64_dropped", sep="\t", header=FALSE)
colnames(cosmic)<-c("cosmicDB","mutation","chr","start","end","ref","alt","line")
merged.data.frame = Reduce(function(...) merge(..., all=T), list.of.data.frames)
write.table(merged.data.frame,file="example_merged_columns.txt", sep="\t", quote
=F, col.names=F, row.names=F)
merged.data.frame = Reduce(function(...) merge(..., all=T), list.of.data.frames)
write.table(merged.data.frame,file="example_merged_columns.txt", sep="\t", quote
=F, col.names=F, row.names=F)

#####merge both by line number and only use and write the table

list.of.data.frames = list(all,ex,allk,exk,clinvar,cadd)
merged.data.frame = Reduce(function(...) merge(..., all=T), list.of.data.frames)
write.table(merged.data.frame,file=coutput, sep="\t", quote=F, col.names=TRUE, row.names=FALSE)

