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
devtools::install_github("pcats-api/pcatsAPIclientR")
```

The Python PCATS REST API abstraction library is also available on github. In order to install it please run:

`python -m pip install pcats_api_client`

## Example
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
#> JobID: e2db813e-89a2-4a35-bfa3-d34b5b2b0d0d

#If the job has been successfully done, the function will return with status="Done"
status <- pcatsAPIclientR::wait_for_result(jobid)
#>$status
[1] "Done"

#To retrieve a job status without waiting for the completion (i.e. polling), one may use the following code.
status <- pcatsAPIclientR::job_status(jobid)

#Step 3. Show the results
if (status=="Done") {
    cat(pcatsAPIclientR::print(jobid))
}
# The first table shows the estimated ATE with SD and the 95% confidence interval.
#>Average treatment effect:
#> Contrast Estimation    SD     LB     UB
#>    0 - 1     -5.048 0.198 -5.422 -4.654

# The second table presents the estimated average potential outcomes by treatment groups. It reports that the expected mean and its standard error for the potential outcomes.
#>Potential outcomes:
#> A Estimation    SD     LB    UB
#> 0     -0.122 0.090 -0.297 0.048
#> 1      4.926 0.111  4.705 5.143

# It’s the link of the histograms of MCMC posterior estimates of ATE
#> Plot URL:  https://pcats.research.cchmc.org/api/job/e2db813e-89a2-4a35-bfa3-d34b5b2b0d0d/plot
 
#It’s the link of the histograms of MCMC posterior estimates of the potential outcomes
#> Plot Potential URL: https://pcats.research.cchmc.org/api/job/e2db813e-89a2-4a35-bfa3-d34b5b2b0d0d/plot/Potential
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
#> Stage 1:
#> Average treatment effect:
#>  Contrast Estimation    SD     LB     UB
#>     0 - 1     -0.435 0.148 -0.732 -0.146

#> Potential outcomes:
#>  A1 Estimation    SD     LB    UB
#>   0      0.067 0.083 -0.107 0.221
#>   1      0.503 0.069  0.382 0.660

# Stage 2 shows the results of the second time point
#> Stage 2:
#> Average treatment effect:
 #>    Contrast Estimation    SD     LB     UB
#>  0, 0 - 0, 1     -3.743 0.472 -4.664 -2.824
#>  0, 0 - 1, 0     -2.668 0.426 -3.467 -1.831
#>  0, 0 - 1, 1     -6.849 0.449 -7.712 -5.980
#>  0, 1 - 1, 0      1.075 0.494  0.217  2.147
#>  0, 1 - 1, 1     -3.106 0.463 -3.977 -2.206
#>  1, 0 - 1, 1     -4.181 0.424 -5.050 -3.387

#> Potential outcomes:
#>  A1 A2 Estimation    SD     LB     UB
#>   0  0     -2.396 0.294 -2.902 -1.768
#>   0  1      1.347 0.346  0.707  2.078
#>   1  0      0.272 0.273 -0.230  0.798
#>   1  1      4.453 0.236  4.015  4.907

# It’s the link of the histograms of MCMC posterior estimates of ATE
#> Plot URL:  https://pcats.research.cchmc.org/api/job/3bf0e733-a381-4525-9a5a-5c8552b634e2/plot

#It’s the link of the histograms of MCMC posterior estimates of the potential outcomes
#> Plot Potential URL: https://pcats.research.cchmc.org/api/job/3bf0e733-a381-4525-9a5a-5c8552b634e2/plot/Potential
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
  print(pcats_api.print(jobid))
```
