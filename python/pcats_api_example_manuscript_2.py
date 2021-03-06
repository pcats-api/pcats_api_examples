import pcats_api_client as pcats_api

#example 2

jobid=pcats_api.staticgp(datafile="../data/example2.csv", 
                         outcome='Y',
                         treatment='A,Z',
                         x_explanatory='X',
                         x_confounding='X',
                         tr_hte='Gender',
                         tr2_values="-1,0,1",
                         tr_type = 'Discrete',
                         tr2_type = "Continuous",
                         burn_num=500,
                         mcmc_num=500,
                         outcome_type='Continuous',
                         method='GP',
                         x_categorical="Gender")

print("JobID: {}".format(jobid))

status = pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.print(jobid))
else:
    print("Error")
    exit()

#example 2 CATE

jobid_cate=pcats_api.staticgp_cate(jobid=jobid,
                              x="Gender",
                              control_tr="0,0",
                              treat_tr="1,0",
                              pr_values="0")

print("CATE JobID: {}".format(jobid_cate))

status = pcats_api.wait_for_result(jobid_cate)

if status=="Done":
    print(pcats_api.print(jobid_cate))
else:
    print("Error")
