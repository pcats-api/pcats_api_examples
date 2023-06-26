# PCATS: Bayesian Causal Inference for General Type of Treatment with R and Python

## INTRODUCTION

The PCATS application programming interface (API) implements two Bayesian's non parametric causal inference modeling, 
Bayesian's Gaussian process regression and Bayesian additive regression tree, and provides estimates of averaged causal treatment (ATE) 
and conditional averaged causal treatment (CATE) for adaptive or non-adaptive treatment. 
The API is able to handle general types of treatment - binary, multilevel, continuous and their combinations, 
as well as general type of outcomes including bounded summary scores such as health related quality of life and survival outcomes. 
In addition, the API is able to deal with missing data using user supplied multiply imputed missing data. 
Summary tables and interactive figures of the results are generated and downloadable.

### Installation

The R PCATS REST API abstraction library is available on github. In order to install it please run:

```R
install.packages("devtools")
devtools::install_github("pcats-api/pcatsAPIclientR",force=TRUE)
```

The Python PCATS REST API abstraction library is also available on github. In order to install it please run:

`python -m pip install git+https://github.com/pcats-api/pcats_api_client_py.git`

## Simple Example
### Non-adaptive treatment
This is a simple example of how to use the package to estimate ATE. The example data is simulated from

```
X~N(0,1)
A | X ~ Bernoulli(expit(-0.2+3 X ))
Y | A,X ~ N(X+5 A,1)
```

The **staticGP** function is used to estimate ATE for non-adaptive treatment. Since the outcome Y is continuous, *outcome.type* is set to ``Continuous``. If Y is binary or counting outcome, outcome.type should be set to ``Discrete``. Similarly, tr.type gives the type of the treatment. In this example, the treatment A is a binary indicator variable, tr.type is set to ``Discrete``. x.explanatory specifies the prognostic variables **W** and x.confounding specifies the confounders **V**. The categorical variables in **W** and **V** should be specified in x.categorical. Users can define a link function by outcome.link. The default value of outcome.link is ``identity``. The number of burn-in Gibbs samples (burn.num) is set to be 500 and number of Gibbs samples after burn-in (mcmc.num) is 500. The default numbers are 500 for burn-in and 500 for Gibbs sampling. 

By default, the estimates of averaged treatment effect and potential outcomes are reported. Two methods, GP and BART, are available for users to choose. For a continuous outcome, users can choose either one. Please note that the time cost associated with the model fit increases sharply for GP method, thus it can be challenging with a large sample size. For a discrete outcome, only BART method is available currently.

There are three steps in calling PCATS API. The first step makes the actual request. The request will be sent to the API, which after executing will send back a response. The second step checks the request status. The last step fetches the results from the API. R and Python code are shown below.

**R code:**

```R
library(pcatsAPIclientR)

#download the data
download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/data/example1.csv", destfile="example1.csv")

#Step 1. Submit the actual request
jobid <- pcatsAPIclientR::staticGP(datafile="example1.csv",
                      outcome="Y",
                      time="Time",
                      outcome.type="Continuous",
                      treatment="A", 
                      tr.type="Discrete",
                      x.explanatory="X",
                      x.confounding="X",
                      burn.num=500, mcmc.num=500,
                      method="GP")

#Step 2. Check the request status
#Get the job id
cat(paste0("JobID: ",jobid,"\n"))
#JobID: e2db813e-89a2-4a35-bfa3-d34b5b2b0d0d

#If the job has been successfully done, the function will return with status="Done"
status <- pcatsAPIclientR::wait_for_result(jobid)
#$status
#[1] "Done"

#To retrieve a job status without waiting for the completion (i.e. polling), one may use the following code.
status <- pcatsAPIclientR::job_status(jobid)

#Step 3. Show the results
if (status=="Done") {
    cat(pcatsAPIclientR::printgp(jobid))
}
# The first table shows the estimated ATE with SD and the 95% confidence interval.
# Average treatment effect:
#   Contrast Estimation    SD     LB     UB
#  A=0 - A=1     -5.048 0.198 -5.415 -4.662

# The second table presents the estimated average potential outcomes by treatment groups. It reports that the expected mean and its standard error for the potential outcomes.
# Potential outcomes:
# A Estimation    SD     LB    UB
# 0     -0.122 0.089 -0.296 0.052
# 1      4.926 0.112  4.708 5.140

# It’s the link of the histograms of MCMC posterior estimates of ATE
# Plot URL:  https://pcats.research.cchmc.org/api/job/e2db813e-89a2-4a35-bfa3-d34b5b2b0d0d/plot
 
# It’s the link of the histograms of MCMC posterior estimates of the potential outcomes
# Plot Potential URL: https://pcats.research.cchmc.org/api/job/e2db813e-89a2-4a35-bfa3-d34b5b2b0d0d/plot/Potential
```

** Python code:**
```python
import pcats_api_client as pcats_api
import requests

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/data/example1.csv")

with open("example1.csv", 'wb') as f:
    f.write(r.content)
    
jobid=pcats_api.staticgp(datafile="example1.csv",
                      outcome='Y',
                      treatment='A',
                      time="Time",   
                      x_explanatory='X',
                      x_confounding='X',
                      burn_num=500,
                      mcmc_num=500,
                      outcome_type='Continuous',
                      method='GP',
                      tr_type='Discrete')

status = pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
```

### Adaptive treatment

The **dynamicGP** function is designed to estimate the average treatment effect (ATE) for data with two time points. This example shows how to use it. The data is generated from the following simulation setting:

```
X ~ N(0,1)
A_1~ Bernoulli(0.5)
L_1  | A_1,X ~ N(0.25+0.3A_1-0.2X,1)
A_2  | L_1,A_1,X ~ Bernoulli(expit(-0.2-0.38A_1+L_1  ))
Y | A_1,X,L_1,A_2  ~ N(-2+2.5A_1+3.5A_2+0.5A_1  A_2-0.6L_1,sd=2)
```

The R code and Python code are shown below:

**R code:**
```R
library(pcatsAPIclientR)

download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/data/example3.csv", destfile="example3.csv")

jobid <- pcatsAPIclientR::dynamicGP(
            datafile='example3.csv',
            stg1.outcome='L1',
            stg1.treatment='A1',
            stg1.time="Time1",
            stg1.x.explanatory='X',
            stg1.x.confounding='X',
            stg1.outcome.type='Continuous',
            stg2.outcome='Y',
            stg2.treatment='A2',
            stg2.time="Time2",
            stg2.x.explanatory='X,L1',
            stg2.x.confounding='X,L1',
            stg2.outcome.type='Continuous',
            burn.num=500,
            mcmc.num=500,
            stg1.tr.type = 'Discrete',
            stg2.tr.type = 'Discrete',
            method='GP')

status <- pcatsAPIclientR::wait_for_result(jobid)
if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobid))
}
# Stage 1:
# Average treatment effect:
#     Contrast Estimation    SD     LB     UB
#  A1=0 - A1=1     -0.435 0.149 -0.743 -0.162

# Potential outcomes:
#  A1 Estimation    SD     LB    UB
#   0      0.068 0.083 -0.106 0.220
#   1      0.502 0.070  0.365 0.637
# 
# Stage 2:
# Average treatment effect:
#                   Contrast Estimation    SD     LB     UB
#  A1=1 & A2=1 - A1=0 & A2=1      3.106 0.472  2.153  3.985
#  A1=1 & A2=1 - A1=0 & A2=0      6.893 0.421  6.075  7.640
#  A1=1 & A2=1 - A1=1 & A2=0      4.191 0.427  3.290  4.976
#  A1=0 & A2=1 - A1=0 & A2=0      3.787 0.468  2.821  4.635
#  A1=0 & A2=1 - A1=1 & A2=0      1.085 0.523  0.127  2.064
#  A1=0 & A2=0 - A1=1 & A2=0     -2.702 0.428 -3.494 -1.849
# 
# Potential outcomes:
#  A1 A2 Estimation    SD     LB     UB
#   1  1      4.467 0.228  4.043  4.937
#   0  1      1.360 0.358  0.625  2.035
#   0  0     -2.426 0.279 -2.915 -1.826
#   1  0      0.276 0.285 -0.323  0.795

# It’s the link of the histograms of MCMC posterior estimates of ATE
# Plot URL:  https://pcats.research.cchmc.org/api/job/3bf0e733-a381-4525-9a5a-5c8552b634e2/plot

# It’s the link of the histograms of MCMC posterior estimates of the potential outcomes
# Plot Potential URL: https://pcats.research.cchmc.org/api/job/3bf0e733-a381-4525-9a5a-5c8552b634e2/plot/Potential
```

**Python code:**
```python
import  pcats_api_client  as  pcats_api
import requests

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/data/example3.csv")

with open("example3.csv", 'wb') as f:
    f.write(r.content)
    
jobid=pcats_api.dynamicgp(datafile="example3.csv", 
                      stg1_outcome='L1',
                      stg1_treatment='A1',
                      stg1_time="Time1",
                      stg1_x_explanatory='X',
                      stg1_x_confounding='X',
                      stg1_outcome_type='Continuous',
                      stg2_outcome='Y',
                      stg2_treatment='A2',
                      stg2_time="Time2",    
                      stg2_x_explanatory='X,L1',
                      stg2_x_confounding='X,L1',
                      stg2_outcome_type='Continuous',
                      burn_num=500,
                      mcmc_num=500,
                      stg1_tr_type = 'Discrete',
                      stg2_tr_type = 'Discrete',
                      method='GP')
status = pcats_api.wait_for_result(jobid)

if  status =="Done":
  print(pcats_api.printgp(jobid))
```

## Case Study Example
### Example 1 (the JIA study)
This is an example of how to use the package to estimate ATE for a JIA study.

The R code and Python code are shown below:

**R code:**
```R
download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1.csv", destfile="example1.csv")
download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example1_midata.csv", destfile="example1_midata.csv")

#Step 1: submit a request 
jobid <- pcatsAPIclientR::staticGP(datafile="example1.csv",
                                   outcome="Jadas6",
                                   treatment="treatment_group", 
                                   #specify the prognostic variables W
                                   x.explanatory="age,Female,chaq_score,RF_pos,private
                                                 ,Jadas0,timediag",
                                   #specify the confounders V
                                   x.confounding="age,Jadas0,chaq_score,timediag",
                            #add the term if you think the treatment effect is dfferent in RF_pos group
                                   tr.hte="RF_pos",   
                                   #specify the time variable,
                                   time="diffvisit",
                                   #specify the time value used to calculate the ATE
                                   time.value=180,
                                   burn.num=500, mcmc.num=500,
                                   #specify the type of outcome
                                   outcome.type="Continuous",
                                   method="GP",
                                   #specify the type of treatment
                                   tr.type="Discrete",
                                   outcome.lb=0,
                                   outcome.ub=40,
                                   outcome.bound_censor="bounded",
                                   x.categorical="Female,RF_pos,private",
                                   #specify the value c used to calculate PrTE
                                   c.margin="0,1",
                                   mi.datafile="example1_midata.csv")
#retrieve the job id
cat(paste0("JobID: ",jobid,"\n"))

#Step 2: check the request status using the job id
#If the job completed successfully, the function will return "Done".
status <- pcatsAPIclientR::wait_for_result(jobid)

#To retrieve a job status without waiting for the completion,  one may use the following code.
status <- pcatsAPIclientR::job_status(jobid)

#Step 3: print the results
if (status=="Done") {
    cat(pcatsAPIclientR::printgp(jobid))
}
# CATE
jobidcate <- pcatsAPIclientR::staticGP.cate(jobid=jobid,
                                            x="RF_pos",
                                            control.tr="1",
                                            treat.tr="0",
                                            c.margin="0,1")

status <- pcatsAPIclientR::wait_for_result(jobidcate)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobidcate))
}

# Average treatment effect (t*=180):
#  Imputation                              Contrast Estimation    SD     LB    UB PrTE(c=0) PrTE(c=1)
#           1 treatment_group=0 - treatment_group=1      3.436 2.219 -0.463 7.724     0.952     0.858
#           2 treatment_group=0 - treatment_group=1      3.399 2.223 -0.706 7.599     0.936     0.864
#           3 treatment_group=0 - treatment_group=1      3.460 2.184 -0.355 7.734     0.948     0.850
#           4 treatment_group=0 - treatment_group=1      3.435 2.200 -0.320 7.774     0.944     0.860
#           5 treatment_group=0 - treatment_group=1      3.453 2.250 -0.678 7.604     0.944     0.846
#    Combined treatment_group=0 - treatment_group=1      3.436 2.214 -0.402 7.824     0.945     0.856
# 
# Potential outcomes (t*=180):
#  Imputation treatment_group Estimation    SD    LB    UB
#           1               0      8.055 0.967 6.205 9.804
#           2               0      8.026 0.973 6.292 9.844
#           3               0      8.059 0.956 6.105 9.721
#           4               0      8.011 0.949 6.217 9.893
#           5               0      8.065 0.968 6.199 9.819
#           1               1      4.619 1.579 1.330 7.300
#           2               1      4.627 1.561 1.914 7.883
#           3               1      4.599 1.561 1.765 7.537
#           4               1      4.576 1.585 1.815 7.472
#           5               1      4.612 1.589 1.582 7.481
#    Combined               0      8.043 0.962 6.165 9.819
#    Combined               1      4.607 1.574 1.527 7.431
#    
# Plot URL: https://pcats.research.cchmc.org/api/job/297c4123-d503-4b24-9f58-abfe08ca4f14/plot
# 
# Plot Potential URL: https://pcats.research.cchmc.org/api/job/297c4123-d503-4b24-9f58-abfe08ca4f14
# 
# Conditional average treatment effect (t*=180):
#  Constrast Imputation RF_pos Estimation    SD     LB     UB PrCTE(c=0) PrCTE(c=1)
#      0 - 1          1      0      2.676 2.418 -1.493  7.376      0.852      0.750
#      0 - 1          2      0      2.622 2.427 -1.969  7.080      0.838      0.718
#      0 - 1          3      0      2.698 2.402 -2.077  6.931      0.856      0.746
#      0 - 1          4      0      2.655 2.379 -1.487  7.301      0.862      0.744
#      0 - 1          5      0      2.663 2.444 -1.258  7.930      0.852      0.744
#      0 - 1          1      1      7.642 5.249 -1.852 18.092      0.932      0.896
#      0 - 1          2      1      7.694 5.230 -1.512 18.540      0.930      0.902
#      0 - 1          3      1      7.674 5.196 -2.332 17.808      0.934      0.914
#      0 - 1          4      1      7.749 5.331 -2.727 17.608      0.926      0.898
#      0 - 1          5      1      7.823 5.230 -1.417 18.058      0.942      0.910
#      0 - 1   Combined      0      2.663 2.412 -1.669  7.389      0.852      0.740
#      0 - 1   Combined      1      7.716 5.244 -1.870 18.196      0.933      0.904
# 
# Plot URL: https://pcats.research.cchmc.org/api/job/a2177819-91d1-4673-bda9-7ff2fd7ad42e/plot
```

**Python code:**
```python
import  pcats_api_client  as  pcats_api
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
        treatment="treatment_group",
        #specify the prognostic variables W
        x_explanatory="age,Female,chaq_score,RF_pos,private,Jadas0,timediag",
        #specify the confounders V
        x_confounding="age,Jadas0,chaq_score,timediag",
        #add the term if you think the treatment effect is dfferent in RF_pos group
        tr_hte="RF_pos",
        #specify the time variable,
        time="diffvisit",
        #specify the time value used to calculate the ATE
        time_value=180,
        burn_num=500,
        mcmc_num=500,
        #specify the type of outcome
        outcome_type="Continuous",
        method="GP",
        #specify the type of treatment
        tr_type="Discrete",
        outcome_lb=0,
        outcome_ub=40,
        outcome_bound_censor="bounded",
        x_categorical="Female,RF_pos,private",
        #specify the value c used to calculate PrTE
        c_margin="0,1",
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
        control_tr="1",
        treat_tr="0",
        c_margin="0,1")

print("CATE JobID: {}".format(jobid_cate))

status=pcats_api.wait_for_result(jobid_cate)

if status=="Done":
    print(pcats_api.printgp(jobid_cate))
else:
    print("Error")
```

### Example 2 (the MOBILITY study)
This is an example of how to use the package to estimate ATE for a MOBILITY study.

The R code and Python code are shown below:

**R code:**
```R
download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2.csv", destfile="example2.csv")

jobid <- pcatsAPIclientR::dynamicGP(datafile="example2.csv",
                                    stg1.outcome='BMI1',
                                    stg1.treatment='A0',
                                    stg1.x.explanatory="MET,Gender,BMI0,AGE,Obesity",
                                    stg1.x.confounding="BMI0,AGE",
                                    stg1.outcome.type='Continuous',
                                    stg1.time = "time1",
                                    stg1.time.value = 90,                                    
                                    stg2.outcome='BMI2',
                                    stg2.treatment='A1',
                                    stg2.x.explanatory="MET,Gender,BMI0,AGE,Obesity,BMI1",
                                    stg2.x.confounding="BMI0,AGE,BMI1", 
                                    stg2.tr2.hte="BMI1",
                                    stg2.outcome.type='Continuous',
                                    stg2.time = "time2",
                                    stg2.time.value = 180,                                      
                                    burn.num=500,
                                    mcmc.num=500,
                                    stg1.tr.type = 'Discrete',
                                    stg2.tr.type = 'Discrete',
                                    method='BART',
                                    x.categorical="MET,Gender,Obesity")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobid))
}

# Stage 1:
# Average treatment effect (t*=90):
#     Contrast Estimation    SD    LB    UB
#  A0=0 - A0=1      0.728 0.215 0.376 1.187
# 
# Potential outcomes (t*=90):
#  A0 Estimation    SD     LB     UB
#   0     29.690 0.155 29.381 29.963
#   1     28.962 0.195 28.575 29.298
# 
# Stage 2:
# Average treatment effect (t_1*=90 & t_2*=180):
#                   Contrast Estimation    SD     LB     UB
#  A0=0 & A1=0 - A0=0 & A1=1      3.130 0.475  2.205  3.771
#  A0=0 & A1=0 - A0=1 & A1=1      5.383 0.250  4.887  5.877
#  A0=0 & A1=0 - A0=1 & A1=0      1.642 0.454  0.774  2.393
#  A0=0 & A1=1 - A0=1 & A1=1      2.253 0.506  1.399  3.223
#  A0=0 & A1=1 - A0=1 & A1=0     -1.488 0.331 -2.180 -0.876
#  A0=1 & A1=1 - A0=1 & A1=0     -3.741 0.405 -4.571 -3.152
# 
# Potential outcomes (t_1*=90 & t_2*=180):
#  A0 A1 Estimation    SD     LB     UB
#   0  0     33.051 0.170 32.701 33.364
#   0  1     29.921 0.437 29.289 30.738
#   1  1     27.668 0.255 27.171 28.192
#   1  0     31.409 0.421 30.702 32.170
#   
# Plot URL: https://pcats.research.cchmc.org/api/job/7f31db9c-bd2c-4b55-8c18-4ea5baa3c396/plot
# 
# Plot Potential URL: https://pcats.research.cchmc.org/api/job/7f31db9c-bd2c-4b55-8c18-4ea5baa3c396/plot/Potential
```

**Python code:**
```python
import pcats_api_client as pcats_api
import requests

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2.csv")

with open("example2.csv", 'wb') as f:
    f.write(r.content)

r = requests.get("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2_midata.csv")

with open("example2_midata.csv", 'wb') as f:
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
```
