import pcats_api_client as pcats_api
import requests

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1.csv")

with open("example1.csv", 'wb') as f:
    f.write(r.content)

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1_midata.csv")

with open("example1_midata.csv", 'wb') as f:
    f.write(r.content)
    
jobid=pcats_api.staticgp(datafile="example1.csv", 
        outcome="Jadas6",
        treatment="treatment_group",
        x_explanatory="age,Female,chaq_score,RF_pos,private,Jadas0,timediag",
        x_confounding="age,Jadas0,chaq_score,diffvisit,timediag",
        burn_num=500,
        mcmc_num=500,
        outcome_type="Continuous",
        method="GP",
        tr_type="Discrete",
        outcome_lb=0,
        outcome_ub=40,
        outcome_bound_censor="bounded",
        x_categorical="Female,RF_pos,private",
        pr_values="5,10,15",
        mi_datafile="example1_midata.csv")

print("JobID: {}".format(jobid))

status=pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
