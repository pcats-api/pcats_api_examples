library(pcatsAPIclientR)

#example 8

jobid <- pcatsAPIclientR::dynamicGP(datafile='example8.csv',

                      stg1.outcome='L1',
                      stg1.treatment='A1',
                      stg1.x.explanatory='U0',
                      stg1.x.confounding='U0',
                      stg1.outcome.type='Discrete',
                      stg1.tr.type = 'Discrete',

                      stg2.outcome='Y',
                      stg2.treatment='A2',
                      stg2.x.explanatory='U0,L1',
                      stg2.x.confounding='U0,L1',
                      stg2.outcome.type='Continuous', 
                      stg2.tr.type = 'Discrete',

                      burn.num=500,
                      mcmc.num=500,
                      method='BART'
                   )

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
   cat(pcatsAPIclientR::print(jobid))
}

