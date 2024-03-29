library(pcatsAPIclientR)

download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1.csv", destfile="example1.csv")
download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1_midata.csv", destfile="example1_midata.csv")

#Step 1: submit a request 
jobid <- pcatsAPIclientR::staticGP(datafile="example1.csv",
                                   outcome="Jadas6",
                                   treatment="treatment_group", 
                                   #specify the prognostic variables W
                                   x.explanatory="age,Female,chaq_score,RF_pos,private
                                                 ,Jadas0,timediag",
                                   #specify the confounders V
                                   x.confounding="age,Jadas0,chaq_score,timediag",
                            #add the term if you think the treatment effect is dfferent in RF_pos group
                                   tr.hte="RF_pos",   
                                   #specify the time variable,
                                   time="diffvisit",
                                   #specify the time value used to calculate the ATE
                                   time.value=180,
                                   burn.num=500, mcmc.num=500,
                                   #specify the type of outcome
                                   outcome.type="Continuous",
                                   method="GP",
                                   #specify the type of treatment
                                   tr.type="Discrete",
                                   outcome.lb=0,
                                   outcome.ub=40,
                                   outcome.bound_censor="bounded",
                                   x.categorical="Female,RF_pos,private",
                                   #specify the value c used to calculate PrTE
                                   c.margin="0,1",
                                   mi.datafile="example1_midata.csv")
#retrieve the job id
cat(paste0("JobID: ",jobid,"\n"))

#Step 2: check the request status using the job id
#If the job completed successfully, the function will return "Done".
status <- pcatsAPIclientR::wait_for_result(jobid)

#To retrieve a job status without waiting for the completion,  one may use the following code.
status <- pcatsAPIclientR::job_status(jobid)

#Step 3: print the results
if (status=="Done") {
    cat(pcatsAPIclientR::printgp(jobid))
}

# CATE
jobidcate <- pcatsAPIclientR::staticGP.cate(jobid=jobid,
                                            x="RF_pos",
                                            control.tr="1",
                                            treat.tr="0",
                                            c.margin="0,1")

status <- pcatsAPIclientR::wait_for_result(jobidcate)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobidcate))
}
