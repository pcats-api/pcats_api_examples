import pcats_api_client as pcats_api

#example 6

jobid=pcats_api.dynamicgp(datafile="example6.csv", 
                      stg1_outcome='L1',
                      stg1_treatment='A1',
                      stg1_x_explanatory='X',
                      stg1_x_confounding='X',
                      stg1_outcome_type='Continuous',
                      stg2_outcome='Y',
                      stg2_treatment='A2',
                      stg2_x_explanatory='X,L1',
                      stg2_x_confounding='X,L1',
                      stg2_outcome_type='Continuous', 
                      burn_num=500,
                      mcmc_num=500,
                      stg1_tr_type = 'Discrete',
                      stg2_tr_type = 'Discrete',
                      method='BART')

print("JobID: {}".format(jobid))

status = pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.print(jobid))
else:
    print("Error")
