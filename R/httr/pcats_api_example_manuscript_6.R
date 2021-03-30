library(httr)

#example 6

res <- POST(url='https://pcats.research.cchmc.org/api/staticgp',
            encode='multipart',
            body=list(data=upload_file("../../data/example6.csv"),
                   outcome="Y",
                   treatment="A",
                   x.explanatory="X",
                   x.confounding="X",
                   burn.num=500, mcmc.num=500,
                   outcome.type="Continuous",
                   method="GP",
                   tr.type="Discrete",
                   outcome.lb=0,
                   outcome.ub="inf",
                   outcome.bound_censor='bounded'
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
