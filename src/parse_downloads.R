#####################################
# Determine if a tool was reachable
# and output an accessibility matrix
#####################################

############# Helper functions ####################
loadFile <- function(fn)
{
  conn <- file(fn, "r")
  i = 1
  res = rep(NA,10^6)
  while(length(line <- readLines(conn, 1)) > 0 & i < 1000) 
  {
    res[i] = paste(line)
    i = i + 1  
  }
  close(conn)
  return(paste(res[1:i],collapse= " "))
}

hasHit <- function(f.value, f.errors)
{
  if (nchar(encodeString(f.value)) < 10)
  {
    return(c(0,nchar(f.value)))	
  }
  found = F
  for(i in 1:length(f.errors))
  {
    if (grepl(f.errors[i], f.value, ignore.case=T))
    {
      found = T	
    }	
  }
  return(c(as.integer(!found), nchar(encodeString(f.value))))
}

getProfileOneDay <- function(f.folder, f.pmids, f.date, f.errors)
{
  print(f.date)
  result = matrix(1,length(f.pmids), 2)
  for (i in 1:length(f.pmids))
  {
    f.fn = paste(f.folder, f.pmids[i],"-",f.date,".txt", sep="")
    temp.site = loadFile(f.fn)
    temp.hit = hasHit(temp.site, f.errors)
    result[i,] = temp.hit	
  }
  return(result)
}

##############################################################

DL_FOLDER = "downloads/"
RESULT_FOLDER = "results/"

dir.create(RESULT_FOLDER, recursive = TRUE)

flist = list.files(DL_FOLDER, pattern=NULL, all.files=FALSE, full.names=FALSE)

pmids = rep("",length(flist))
dates = rep("",length(flist))

for(i in 1 : length(flist))
{
	print(i)
	pmids[i] = substr(flist[i],1,8)
	dates[i] = substr(flist[i],10,19)
}

udates = unique(dates) 
upmids = unique(pmids)

errors = readLines("data/error-phrases.txt")

###### Create binary working matrix #############

day.profile = c()

for (i in 1:length(udates))
{
	day.profile = cbind(day.profile,
	                    getProfileOneDay(DL_FOLDER, upmids, udates[i], errors))
	print(c(i, dim(day.profile)))
}

work.mat = day.profile[, seq(1, ncol(day.profile), 2)]
colnames(work.mat) = udates

write.table(cbind(upmids,work.mat),
            file.path(RESULT_FOLDER, "working-matrix-binary.txt"),
            row.name=F, col.name=T, quote = F, sep="\t")

