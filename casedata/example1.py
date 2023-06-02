import pcats_api_client as pcats_api
import requests

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1.csv")

with open("example1.csv", 'wb') as f:
    f.write(r.content)

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1_midata.csv")

with open("example1_midata.csv", 'wb') as f:
    f.write(r.content)

#Step 1: submit a request
jobid=pcats_api.staticgp(datafile="example1.csv", 
        outcome="Jadas6",
        treatment="treatment_group,diffvisit",
        #specify the prognostic variables W
        x_explanatory="age,Female,chaq_score,RF_pos,private,Jadas0,timediag",
        #specify the confounders V
        x_confounding="age,Jadas0,chaq_score,timediag",
        #add the term if you think the treatment effect is dfferent in RF_pos group
        tr_hte="RF_pos",
        tr2_values=180,
        burn_num=500,
        mcmc_num=500,
        #specify the type of outcome
        outcome_type="Continuous",
        method="GP",
        #specify the type of treatment
        tr_type="Discrete",
        tr2_type = "Continuous",
        outcome_lb=0,
        outcome_ub=40,
        outcome_bound_censor="bounded",
        x_categorical="Female,RF_pos,private",
        #specify the value c used to calculate PrTE
        pr_values="5",
        mi_datafile="example1_midata.csv")

#retrieve the job id
print("JobID: {}".format(jobid))

#Step 2: check the request status using the job id
#If the job completed successfully, the function will return "Done".
status=pcats_api.wait_for_result(jobid)

#Step 3: print the results
if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
    
#CATE

jobid_cate=pcats_api.staticgp_cate(jobid=jobid,
        x="RF_pos",
        control_tr="0,180",
        treat_tr="1,180",
        pr_values="5")

print("CATE JobID: {}".format(jobid_cate))

status=pcats_api.wait_for_result(jobid_cate)

if status=="Done":
    print(pcats_api.printgp(jobid_cate))
else:
    print("Error")    
