library(pcatsAPIclientR)

download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2.csv", destfile="example2.csv")

download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2_midata.csv", destfile="example2_midata.csv")

jobid <- pcatsAPIclientR::dynamicGP(datafile="example2.csv",
                                    stg1.outcome='BMI1',
                                    stg1.treatment='A0',
                                    stg1.x.explanatory="MET,Gender,BMI0,AGE,Obesity,time1",
                                    stg1.x.confounding="BMI0,AGE,time1",
                                    stg1.outcome.type='Continuous',
                                    stg2.outcome='BMI2',
                                    stg2.treatment='A1',
                                    stg2.x.explanatory="MET,Gender,BMI0,AGE,Obesity,time1
                                                       ,time2,BMI1",
                                    stg2.x.confounding="BMI0,AGE,time1,time2,BMI1", 
                                    stg2.tr2.hte="BMI1",
                                    stg2.outcome.type='Continuous',
                                    burn.num=500,
                                    mcmc.num=500,
                                    stg1.tr.type = 'Discrete',
                                    stg2.tr.type = 'Discrete',
                                    method='BART',
                                    x.categorical="MET,Gender,Obesity",
                                    mi.datafile="example2_midata.csv")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobid))
}
