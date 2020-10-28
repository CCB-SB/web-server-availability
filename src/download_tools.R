########################################
# Download the HTML files of every URL
#######################################

OUTPUT_FOLDER = "downloads"
INPUT_FILE = "data/pmids_and_urls.txt"

urllist = read.table(INPUT_FILE, sep="\t", header=T, comment.char="")

urllist.pmid = urllist[,1]
urllist.url = urllist[,2]

dir.create(OUTPUT_FOLDER, recursive=TRUE)

for(i in 1:length(urllist.url))
{
	print(i)
	filename = file.path(OUTPUT_FOLDER, paste(urllist.pmid[i], "-", paste(Sys.Date()),".txt", sep=""))
	write.table("",filename,row.names=F,col.names=F,quote=F)
	try(download.file(paste(urllist.url[i]),filename, method="curl", extra="-m 30 -L"))
}
