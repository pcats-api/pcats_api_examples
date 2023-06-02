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
    cat(pcatsAPIclientR::print(jobid))
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
                      tr_type='Discrete',
                      pr_values='0,1,2')

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
  cat(pcatsAPIclientR::print(jobid))
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
