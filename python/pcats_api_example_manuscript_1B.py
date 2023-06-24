import pcats_api_client as pcats_api
 
#example 1

jobid=pcats_api.staticgp(datafile="../data/example1.csv", 
        outcome="Y",
        treatment="A",
        time="Time",
        x_explanatory="X",
        x_confounding="X",
        burn_num=500,
        mcmc_num=500,
        outcome_type="Continuous",
        method="BART",
        tr_type="Discrete",
        c_margin="0")

print("JobID: {}".format(jobid))

status=pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
