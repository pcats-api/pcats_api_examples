library(pcatsAPIclientR)

#example 3

jobid <- pcatsAPIclientR::dynamicGP(datafile="../../data/example3.csv",
        stg1.outcome="L1",
        stg1.treatment="A1",
        stg1.x.explanatory="X",
        stg1.x.confounding="X",
        stg1.outcome.type="Continuous",
        stg2.outcome="Y",
        stg2.treatment="A2",
        stg2.x.explanatory="X,L1",
        stg2.x.confounding="X,L1",
        stg2.outcome.type="Continuous", 
        burn.num=500,
        mcmc.num=500,
        stg1.tr.type="Discrete",
        stg2.tr.type="Discrete",
        method="GP")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::printgp(jobid))
}

