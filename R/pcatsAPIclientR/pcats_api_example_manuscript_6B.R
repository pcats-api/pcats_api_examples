library(pcatsAPIclientR)

#example 6

jobid <- pcatsAPIclientR::staticGP(datafile="../../data/example6.csv",
                   outcome="Y",
                   treatment="A",
                   x.explanatory="X",
                   x.confounding="X",
                   burn.num=500, mcmc.num=500,
                   outcome.type="Continuous",
                   method="BART"                   
                   )

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::print(jobid))
}
