import pcats_api_client as pcats_api

#example 6

jobid=pcats_api.staticgp(datafile="../data/example6.csv", 
                         outcome='Y',
                         treatment='A',
                         x_explanatory='X',
                         x_confounding='X',
                         burn_num=500,
                         mcmc_num=500,
                         outcome_type='Continuous',
                         method='BART')

print("JobID: {}".format(jobid))

status = pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")

