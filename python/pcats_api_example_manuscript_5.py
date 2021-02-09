import pcats_api_client as pcats_api

jobid=pcats_api.staticgp(datafile="example5.csv",
                         outcome='Y',
                         treatment='A',
                         x_explanatory='X',
                         x_confounding='X',
                         burn_num=500,
                         mcmc_num=500,
                         outcome_type='Continuous',
                         tr_type='Discrete',
                         method='GP',
                         mi_datafile='example5_midata.csv')

print("JobID: {}".format(jobid))

status = pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.print(jobid))
else:
    print("Error")
