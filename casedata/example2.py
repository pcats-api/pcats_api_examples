import pcats_api_client as pcats_api
import requests

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2.csv")

with open("example2.csv", 'wb') as f:
    f.write(r.content)

jobid=pcats_api.dynamicgp(datafile="example2.csv", 
        stg1_outcome="BMI1",
        stg1_treatment="A0",
        stg1_x_explanatory="MET,Gender,BMI0,AGE,Obesity",
        stg1_x_confounding="BMI0,AGE",
        stg1_outcome_type="Continuous",
        stg1_time = "time1",
        stg1_time_value = 90, 
        stg2_outcome="BMI2",
        stg2_treatment="A1",
        stg2_x_explanatory="MET,Gender,BMI0,AGE,Obesity,BMI1",
        stg2_x_confounding="BMI0,AGE,BMI1",
        stg2_tr2_hte="BMI1",
        stg2_outcome_type="Continuous",
        stg2_time = "time2",
        stg2_time_value = 180,         
        burn_num=500,
        mcmc_num=500,
        stg1_tr_type="Discrete",
        stg2_tr_type="Discrete",
        method="BART",
        x_categorical="MET,Gender,Obesity")

print("JobID: {}".format(jobid))

status=pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
