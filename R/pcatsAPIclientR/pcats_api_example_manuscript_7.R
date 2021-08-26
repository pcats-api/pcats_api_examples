library(pcatsAPIclientR)

#example 7

jobid <- pcatsAPIclientR::staticGP(datafile="../../data/example7.csv",
        outcome="Y",
        treatment="A",
        x.explanatory="X",
        x.confounding="X",
        burn.num=500,
        mcmc.num=500,
        outcome.type="Continuous",
        method="GP",
        outcome.censor.lv="lv",
        outcome.censor.uv="uv",
        outcome.bound_censor="censored",
        outcome.censor.yn="censor")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::printgp(jobid))
}
