library(pcatsAPIclientR)

download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2.csv", destfile="example2.csv")

jobid <- pcatsAPIclientR::dynamicGP(datafile="example2.csv",
                                    stg1.outcome='BMI1',
                                    stg1.treatment='A0',
                                    stg1.x.explanatory="MET,Gender,BMI0,AGE,Obesity",
                                    stg1.x.confounding="BMI0,AGE",
                                    stg1.outcome.type='Continuous',
                                    stg1.time = "time1",
                                    stg1.time.value = 90,                                    
                                    stg2.outcome='BMI2',
                                    stg2.treatment='A1',
                                    stg2.x.explanatory="MET,Gender,BMI0,AGE,Obesity,BMI1",
                                    stg2.x.confounding="BMI0,AGE,BMI1", 
                                    stg2.tr2.hte="BMI1",
                                    stg2.outcome.type='Continuous',
                                    stg2.time = "time2",
                                    stg2.time.value = 180,                                      
                                    burn.num=500,
                                    mcmc.num=500,
                                    stg1.tr.type = 'Discrete',
                                    stg2.tr.type = 'Discrete',
                                    method='BART',
                                    x.categorical="MET,Gender,Obesity")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobid))
}
