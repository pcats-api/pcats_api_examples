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
# Contrast Estimation    SD     LB     UB
#    0 - 1     -5.048 0.198 -5.415 -4.662

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
            stg1.x.explanatory='X',
            stg1.x.confounding='X',
            stg1.outcome.type='Continuous',
            stg2.outcome='Y',
            stg2.treatment='A2',
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
# Stage 1 shows the results of the first time point
# Stage 1:
# Average treatment effect:
# Contrast Estimation    SD     LB     UB
#    0 - 1     -0.435 0.149 -0.743 -0.162

# Potential outcomes:
# A1 Estimation    SD     LB    UB
#  0      0.068 0.083 -0.106 0.220
#  1      0.502 0.070  0.365 0.637

# Stage 2 shows the results of the second time point
# Stage 2:
# Average treatment effect:
#    Contrast Estimation    SD     LB     UB
# 0, 0 - 0, 1     -3.787 0.468 -4.635 -2.821
# 0, 0 - 1, 0     -2.702 0.428 -3.494 -1.849
# 0, 0 - 1, 1     -6.893 0.421 -7.640 -6.075
# 0, 1 - 1, 0      1.085 0.523  0.127  2.064
# 0, 1 - 1, 1     -3.106 0.472 -3.985 -2.153
# 1, 0 - 1, 1     -4.191 0.427 -4.976 -3.290

# Potential outcomes:
# A1 A2 Estimation    SD     LB     UB
#  0  0     -2.426 0.279 -2.915 -1.826
#  0  1      1.360 0.358  0.625  2.035
#  1  0      0.276 0.285 -0.323  0.795
#  1  1      4.467 0.228  4.043  4.937

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

jobid <- pcatsAPIclientR::staticGP(datafile="example1.csv",
                                   outcome="Jadas6",
                                   treatment="treatment_group,diffvisit", 
                                   #specify the prognostic variables W
                                   x.explanatory="age,Female,chaq_score,RF_pos,private
                                                 ,Jadas0,timediag",
                                   #specify the confounders V
                                   x.confounding="age,Jadas0,chaq_score,timediag",
                            #add the term if you think the treatment effect is dfferent in RF_pos group
                                   tr.hte="RF_pos",            
                                   tr2.values=180,
                                   burn.num=500, mcmc.num=500,
                                   #specify the type of outcome
                                   outcome.type="Continuous",
                                   method="GP",
                                   #specify the type of treatment
                                   tr.type="Discrete",
                                   tr2.type = "Continuous",
                                   outcome.lb=0,
                                   outcome.ub=40,
                                   outcome.bound_censor="bounded",
                                   x.categorical="Female,RF_pos,private",
                                   #specify the value c used to calculate PrTE
                                   pr.values="5",
                                   mi.datafile="example1_midata.csv")

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
    cat(pcatsAPIclientR::printgp(jobid))
}

# CATE
jobidcate <- pcatsAPIclientR::staticGP.cate(jobid=jobid,
                                            x="RF_pos",
                                            control.tr="0,180",
                                            treat.tr="1,180",
                                            pr.values="5")

status <- pcatsAPIclientR::wait_for_result(jobidcate)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobidcate))
}

# Average treatment effect:
#  Imputation        Contrast Estimation    SD     LB    UB
#           1 0, 180 - 1, 180      3.829 2.092  0.217 8.293
#           2 0, 180 - 1, 180      3.793 2.051 -0.196 7.520
#           3 0, 180 - 1, 180      3.832 2.061  0.384 8.442
#           4 0, 180 - 1, 180      3.817 2.051 -0.220 7.897
#           5 0, 180 - 1, 180      3.826 2.081 -0.247 7.717
#    Combined 0, 180 - 1, 180      3.819 2.066 -0.230 7.824

# Potential outcomes:
#  Imputation treatment_group diffvisit Estimation    SD    LB     UB
#           1               0       180      8.381 0.844 6.868  9.981
#           2               0       180      8.354 0.829 6.903 10.089
#           3               0       180      8.384 0.842 6.720  9.921
#           4               0       180      8.335 0.830 6.819  9.943
#           5               0       180      8.376 0.842 6.763 10.000
#           1               1       180      4.552 1.516 1.764  7.880
#           2               1       180      4.561 1.499 1.956  7.856
#           3               1       180      4.552 1.500 1.602  7.614
#           4               1       180      4.518 1.495 1.751  7.576
#           5               1       180      4.549 1.532 1.829  7.874
#    Combined               0       180      8.366 0.837 6.798 10.011
#    Combined               1       180      4.547 1.507 1.825  7.861
 
# Average treatment effect for for Pr(Y>c):
#  Imputation        Contrast      Pr Estimation    SD     LB    UB
#           1 0, 180 - 1, 180 Pr(Y>5)      0.254 0.148 -0.071 0.500
#           2 0, 180 - 1, 180 Pr(Y>5)      0.251 0.143  0.000 0.551
#           3 0, 180 - 1, 180 Pr(Y>5)      0.253 0.149 -0.041 0.531
#           4 0, 180 - 1, 180 Pr(Y>5)      0.253 0.146 -0.020 0.551
#           5 0, 180 - 1, 180 Pr(Y>5)      0.253 0.149 -0.020 0.531
#    Combined 0, 180 - 1, 180 Pr(Y>5)      0.253 0.147 -0.061 0.510

# Potential outcomes for for Pr(Y>c):
#  Imputation treatment_group diffvisit      Pr Estimation    SD    LB    UB
#           1               0       180 Pr(Y>5)      0.696 0.060 0.561 0.796
#           2               0       180 Pr(Y>5)      0.695 0.059 0.571 0.806
#           3               0       180 Pr(Y>5)      0.696 0.062 0.582 0.816
#           4               0       180 Pr(Y>5)      0.693 0.060 0.582 0.796
#           5               0       180 Pr(Y>5)      0.697 0.060 0.571 0.796
#           1               1       180 Pr(Y>5)      0.442 0.119 0.255 0.724
#           2               1       180 Pr(Y>5)      0.445 0.116 0.204 0.653
#           3               1       180 Pr(Y>5)      0.443 0.119 0.214 0.673
#           4               1       180 Pr(Y>5)      0.440 0.117 0.204 0.653
#           5               1       180 Pr(Y>5)      0.444 0.120 0.224 0.673
#    Combined               0       180 Pr(Y>5)      0.696 0.060 0.561 0.796
#    Combined               1       180 Pr(Y>5)      0.443 0.118 0.194 0.663

# Plot URL: https://pcats.research.cchmc.org/api/job/297c4123-d503-4b24-9f58-abfe08ca4f14/plot

# Plot Potential URL: https://pcats.research.cchmc.org/api/job/297c4123-d503-4b24-9f58-abfe08ca4f14/plot/Potential

# Conditional average treatment effect:
#                                                              Constrast
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  Imputation RF_pos Estimation    SD      LB    UB
#           1      0     -2.969 2.282  -7.200 1.831
#           2      0     -2.924 2.244  -7.470 1.442
#           3      0     -2.970 2.258  -7.454 1.334
#           4      0     -2.944 2.227  -6.978 1.711
#           5      0     -2.948 2.271  -7.227 1.578
#           1      1     -8.587 5.028 -19.650 0.315
#           2      1     -8.598 5.074 -17.496 2.146
#           3      1     -8.605 5.136 -18.856 0.993
#           4      1     -8.645 5.193 -19.028 0.373
#           5      1     -8.690 5.048 -18.141 1.341
#    Combined      0     -2.951 2.255  -7.175 1.767
#    Combined      1     -8.625 5.092 -19.112 0.941

# Conditional average treatment effect for Pr(Y>c):
#                                                              Constrast
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  treatment_group=1 & diffvisit=180 - treatment_group=0 & diffvisit=180
#  Imputation      Pr RF_pos Estimation    SD     LB     UB
#           1 Pr(Y>5)      0     -0.217 0.168 -0.530  0.108
#           2 Pr(Y>5)      0     -0.213 0.165 -0.554  0.084
#           3 Pr(Y>5)      0     -0.216 0.170 -0.530  0.120
#           4 Pr(Y>5)      0     -0.215 0.167 -0.542  0.120
#           5 Pr(Y>5)      0     -0.216 0.170 -0.542  0.084
#           1 Pr(Y>5)      1     -0.462 0.250 -0.933  0.000
#           2 Pr(Y>5)      1     -0.461 0.246 -0.933  0.000
#           3 Pr(Y>5)      1     -0.454 0.253 -0.867  0.000
#           4 Pr(Y>5)      1     -0.464 0.247 -0.933 -0.067
#           5 Pr(Y>5)      1     -0.454 0.240 -0.800  0.067
#    Combined Pr(Y>5)      0     -0.215 0.168 -0.530  0.120
#    Combined Pr(Y>5)      1     -0.459 0.247 -0.867  0.000

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

status=pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
    
#CATE

jobid_cate=pcats_api.staticgp_cate(jobid=jobid,
        x="RF_pos",
        control_tr="0",
        treat_tr="1",
        pr_values="5")

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

download.file("https://github.com/pcats-api/pcats_api_examples/raw/main/casedata/example2_midata.csv", destfile="example2_midata.csv")

jobid <- pcatsAPIclientR::dynamicGP(datafile="example2.csv",
                                    #stage 1
                                    stg1.outcome='BMI1',
                                    stg1.treatment='A0',
                                    stg1.x.explanatory="MET,Gender,BMI0,AGE,Obesity,time1",
                                    stg1.x.confounding="BMI0,AGE,time1",
                                    stg1.outcome.type='Continuous',
                                    stg1.tr.type = 'Discrete',
                                    #stage 2
                                    stg2.outcome='BMI2',
                                    stg2.treatment='A1',
                                    stg2.x.explanatory="MET,Gender,BMI0,AGE,Obesity,time1
                                                       ,time2,BMI1",
                                    stg2.x.confounding="BMI0,AGE,time1,time2,BMI1", 
                                    stg2.tr2.hte="BMI1",
                                    stg2.outcome.type='Continuous',
                                    stg2.tr.type = 'Discrete',
                                    burn.num=500,
                                    mcmc.num=500,   
                                    method='BART',
                                    x.categorical="MET,Gender,Obesity",
                                    mi.datafile="example2_midata.csv")

cat(paste0("JobID: ",jobid,"\n"))

status <- pcatsAPIclientR::wait_for_result(jobid)

if (status=="Done") {
  cat(pcatsAPIclientR::printgp(jobid))
}

# Stage 1:
# Average treatment effect:
#  Imputation Contrast Estimation    SD    LB    UB
#           1    0 - 1      0.962 0.209 0.564 1.345

# Potential outcomes:
#  Imputation A0 Estimation    SD     LB     UB
#           1  0     29.521 0.435 28.672 30.105
#           1  1     28.559 0.380 27.785 29.132

# Stage 2:
# Average treatment effect:
#  Imputation    Contrast Estimation    SD     LB     UB
#           1 0, 0 - 0, 1      3.502 0.267  3.015  4.071
#           1 0, 0 - 1, 0      2.115 0.301  1.529  2.701
#           1 0, 0 - 1, 1      5.585 0.257  5.071  6.088
#           1 0, 1 - 1, 0     -1.387 0.370 -2.151 -0.688
#           1 0, 1 - 1, 1      2.083 0.313  1.439  2.663
#           1 1, 0 - 1, 1      3.470 0.197  3.053  3.857

# Potential outcomes:
#  Imputation A0 A1 Estimation    SD     LB     UB
#           1  0  0     32.981 0.211 32.531 33.358
#           1  0  1     29.479 0.258 28.971 29.974
#           1  1  0     30.866 0.306 30.277 31.487
#           1  1  1     27.396 0.253 26.904 27.885

# Plot URL: https://pcats.research.cchmc.org/api/job/7f31db9c-bd2c-4b55-8c18-4ea5baa3c396/plot

# Plot Potential URL: https://pcats.research.cchmc.org/api/job/7f31db9c-bd2c-4b55-8c18-4ea5baa3c396/plot/Potential

# Plot URL: https://pcats.research.cchmc.org/api/job/a2177819-91d1-4673-bda9-7ff2fd7ad42e/plot
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
        stg1_x_explanatory="MET,Gender,BMI0,AGE,Obesity,time1",
        stg1_x_confounding="BMI0,AGE,time1",
        stg1_outcome_type="Continuous",
        stg2_outcome="BMI2",
        stg2_treatment="A1",
        stg2_x_explanatory="MET,Gender,BMI0,AGE,Obesity,time1,time2,BMI1",
        stg2_x_confounding="BMI0,AGE,time1,time2,BMI1",
        stg2_tr2_hte="BMI1",
        stg2_outcome_type="Continuous", 
        burn_num=500,
        mcmc_num=500,
        stg1_tr_type="Discrete",
        stg2_tr_type="Discrete",
        method="BART",
        x_categorical="MET,Gender,Obesity",
        mi_datafile="example2_midata.csv")

print("JobID: {}".format(jobid))

status=pcats_api.wait_for_result(jobid)

if status=="Done":
    print(pcats_api.printgp(jobid))
else:
    print("Error")
```
