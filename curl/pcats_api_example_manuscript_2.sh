#!/bin/bash

jobid=`curl -s -X POST "https://pcats.research.cchmc.org/api/staticgp" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" \
       -F "data=@example2.csv;type=text/csv" \
       -F "outcome=Y" \
       -F "treatment=A" \
       -F "x.explanatory=X" \
       -F "x.confounding=X" \
       -F "burn.num=500" \
       -F "mcmc.num=500" \
       -F "outcome.type=Continuous" \
       -F "tr.type=Discrete" \
       -F "outcome.lb=0" \
       -F "outcome.ub=inf" \
       -F "outcome.bound_censor=bounded" \
       -F "method=GP" | jq -r .jobid`

echo "JobID: $jobid"

status="Pending"

while [ "$status" == "Pending" ] ;
do
   status="`curl -s -X GET \"https://pcats.research.cchmc.org/api/job/$jobid/status\" -H  \"accept: application/json\" | jq -r .status`"
   sleep 1
done

if [ "$status" == "Done" ] ; then
   curl -s -X GET "https://pcats.research.cchmc.org/api/job/$jobid/print"
   echo ""
else
   echo "Unexpected status is $status" 
fi
