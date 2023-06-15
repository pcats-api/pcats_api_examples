library(pcatsAPIclientR)

#example 2

jobid <- pcatsAPIclientR::staticGP(datafile="../../data/example2.csv",
                                   outcome="Y",
                                   treatment="A",
                                   time="Time",
                                   x.explanatory="X,Z",
                                   x.confounding="X,Z",
                                   tr.hte="Gender,Z",
                                   tr.type="Discrete",
                                   tr2.values="-1,0,1",
                                   tr2.type="Continuous",
                                   burn.num=500,
                                   mcmc.num=500,
                                   outcome.type="Continuous",
                                   method="GP",
                                   x.categorical="Gender")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::printgp(jobid))
}

#example 2 CATE

jobidcate <- pcatsAPIclientR::staticGP.cate(jobid=jobid,
        x="Gender",
        control.tr="0,0",
        treat.tr="1,0",
        c.margin="0")

cat(paste0("JobID cate: ",jobidcate,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobidcate)

if (status=="Done") {
   cat(pcatsAPIclientR::printgp(jobidcate))
}

