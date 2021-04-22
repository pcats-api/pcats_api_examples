library(httr)

#example 4


res <- POST(url='https://pcats.research.cchmc.org/api/dynamicgp',
            encode='multipart',
            body=list(data=upload_file("../../data/example4.csv"),
                      stg1.outcome='L1',
                      stg1.treatment='A1',
                      stg1.x.explanatory='X,M',
                      stg1.x.confounding='X,M',
                      stg1.outcome_type='Continuous',
                      stg1.tr.hte="M",   
                      stg2.outcome='Y',
                      stg2.treatment='A2',
                      stg2.x.explanatory='X,L1,M',
                      stg2.x.confounding='X,L1,M',
                      stg2.outcome.type='Continuous', 
                      stg2.tr2.hte="M",     
                      burn.num=500,
                      mcmc.num=500,
                      stg1.tr.type = 'Discrete',
                      stg2.tr.type = 'Discrete',
                      x.categorical="M",
                      method='GP'))

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

#example 4 CATE

rescate <- POST(url=paste0('https://pcats.research.cchmc.org/api/job/',jobid,'/dynamicgp.cate'),
            encode='multipart',
            body=list(jobid=jobid,
                   x="M",
                   control.tr="0,0",
                   treat.tr="1,0"
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

