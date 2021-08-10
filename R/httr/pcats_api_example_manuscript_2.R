library(httr)

#example 2

res <- POST(url='https://pcats.research.cchmc.org/api/staticgp',
            encode='multipart',
            body=list(data=upload_file("../../data/example2.csv"),
                   outcome="Y",
                   treatment="A,Z",
                   x.explanatory="X",
                   x.confounding="X",
                   tr.hte="Gender",
                   tr.type="Discrete",
                   tr2.values="-1,0,1",
                   tr2.type="Continuous",
                   burn.num=500, mcmc.num=500,
                   outcome.type="Continuous",
                   method="GP",
                   seed="5000",
                   x.categorical='Gender'
                   ))
cont <- content(res)
jobid <- cont$jobid

cat(paste0("JobID: ",jobid,"\n"))

while (TRUE)
{
  status<-jsonlite::fromJSON(paste0("https://pcats.research.cchmc.org/api/job/",jobid,"/status"))
  if (status=="Done") {
    cat(paste(readLines(paste0('https://pcats.research.cchmc.org/api/job/',jobid,'/print'),warn=FALSE), sep="\n", collapse = "\n"))
    cat("\n")
  }
  if (status!="Pending") {
    break;
  }
  # if status.startswith("Error"):
  # exit
  Sys.sleep(1)
}


# cat(paste(readLines(paste0('https://pcats.research.cchmc.org/api/job/',jobid,'/plot'),warn=FALSE), sep="\n", collapse = "\n"))

#example 2 CATE

rescate <- POST(url=paste0('https://pcats.research.cchmc.org/api/job/',jobid,'/staticgp.cate'),
            encode='multipart',
            body=list(staticgp.jobid=jobid,
                   x="Gender",
                   control.tr="0,0",
                   treat.tr="1,0",
                   pr.values="0"
                   ))
contcate <- content(rescate)
jobidcate <- contcate$jobid

cat(paste0("CATE JobID: ",jobidcate,"\n"))

while (TRUE)
{
  status<-jsonlite::fromJSON(paste0("https://pcats.research.cchmc.org/api/job/",jobidcate,"/status"))
  if (status=="Done") {
    cat(paste(readLines(paste0('https://pcats.research.cchmc.org/api/job/',jobidcate,'/print'),warn=FALSE), sep="\n", collapse = "\n"))
    cat("\n")
  }
  if (status!="Pending") {
    break;
  }
  # if status.startswith("Error"):
  # exit
  Sys.sleep(1)
}

