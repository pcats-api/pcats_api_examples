import pcats_api_client as pcats_api

#example 7

jobid=pcats_api.staticgp(datafile="../data/example7.csv", 
        outcome="Y",
        treatment="A",
        x_explanatory="X",
        x_confounding="X",
        burn_num=500,
        mcmc_num=500,
        outcome_type="Continuous",
        method="GP",
        outcome_censor_lv="lv",
        outcome_censor_uv="uv",
        outcome_bound_censor="censored",
        outcome_censor_yn="censor")

print("JobID: {}".format(jobid))

status=pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
