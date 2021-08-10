library(httr)

#example 3


res <- POST(url='https://pcats.research.cchmc.org/api/dynamicgp',
            encode='multipart',
            body=list(data=upload_file("../../data/example3.csv"),
                      stg1.outcome='L1',
                      stg1.treatment='A1',
                      stg1.x.explanatory='X',
                      stg1.x.confounding='X',
                      stg1.outcome.type='Continuous',
                      stg2.outcome='Y',
                      stg2.treatment='A2',
                      stg2.x.explanatory='X,L1',
                      stg2.x.confounding='X,L1',
                      stg2.outcome.type='Continuous', 
                      burn.num=500,
                      mcmc.num=500,
                      stg1.tr.type = 'Discrete',
                      stg2.tr.type = 'Discrete',
                      seed="5000",
                      method='BART'))

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
