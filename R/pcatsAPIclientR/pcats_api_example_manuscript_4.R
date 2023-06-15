library(pcatsAPIclientR)

#example 4

jobid <- pcatsAPIclientR::dynamicGP(datafile="../../data/example4.csv",
                                    stg1.outcome="L1",
                                    stg1.treatment="A1",
                                    stg1.time="Time1",
                                    stg1.x.explanatory="X,M",
                                    stg1.x.confounding="X,M",
                                    stg1.outcome.type="Continuous",
                                    stg1.tr.hte="M",   
                                    stg1.tr.type="Discrete",
                                    stg2.outcome="Y",
                                    stg2.treatment="A2",
                                    stg2.time="Time2",
                                    stg2.x.explanatory="X,L1,M",
                                    stg2.x.confounding="X,L1,M",
                                    stg2.outcome.type="Continuous", 
                                    stg2.tr2.hte="M",     
                                    stg2.tr.type="Discrete",
                                    burn.num=500,
                                    mcmc.num=500,
                                    x.categorical="M",
                                    method="GP")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::printgp(jobid))
}

# CATE
jobidcate <- pcatsAPIclientR::dynamicGP.cate(
        jobid=jobid,
        x="M",
        control.tr="0,0",
        treat.tr="1,0")

cat(paste0("JobIDCate: ",jobidcate,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobidcate)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobidcate))
}

