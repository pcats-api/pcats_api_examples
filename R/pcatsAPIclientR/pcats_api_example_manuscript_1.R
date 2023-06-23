library(pcatsAPIclientR)

#example 1

jobid <- pcatsAPIclientR::staticGP(datafile="../../data/example1.csv",
                                   outcome="Y",
                                   treatment="A",
                                   time="Time",
                                   x.explanatory="X",
                                   x.confounding="X",
                                   burn.num=500, mcmc.num=500,
                                   outcome.type="Continuous",
                                   method="GP",
                                   tr.type="Discrete",
                                   c.margin="0")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::printgp(jobid))
}
