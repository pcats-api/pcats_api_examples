#!/bin/bash

jobid=`curl -s -X POST "https://pcats.research.cchmc.org/api/dynamicgp" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" \
       -F "data=@../data/example5.csv;type=text/csv" \
       -F "stg1.outcome=L1" \
       -F "stg1.treatment=A1" \
       -F "stg1.x.explanatory=U0" \
       -F "stg1.x.confounding=U0" \
       -F "stg1.outcome.type=Discrete" \
       -F "stg1.tr.type=Discrete" \
       -F "stg2.outcome=Y" \
       -F "stg2.treatment=A2" \
       -F "stg2.x.explanatory=U0,L1" \
       -F "stg2.x.confounding=U0,L1" \
       -F "stg2.outcome.type=Continuous" \
       -F "stg2.tr.type=Discrete" \
       -F "burn.num=500" \
       -F "mcmc.num=500" \
       -F "method=BART" | jq -r .jobid`

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

