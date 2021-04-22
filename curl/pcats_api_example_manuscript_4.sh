#!/bin/bash

jobid=`curl -s -X POST "https://pcats.research.cchmc.org/api/dynamicgp" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" \
       -F "data=@../data/example4.csv;type=text/csv" \
       -F "stg1.outcome=L1" \
       -F "stg1.treatment=A1" \
       -F "stg1.x.explanatory=X,M" \
       -F "stg1.x.confounding=X,M" \
       -F "stg1.outcome_type=Continuous" \
       -F "stg1.tr.hte=M" \
       -F "stg2.outcome=Y" \
       -F "stg2.treatment=A2" \
       -F "stg2.x.explanatory=X,L1,M" \
       -F "stg2.x.confounding=X,L1,M" \
       -F "stg2.outcome.type=Continuous" \
       -F "stg2.tr2.hte=M" \
       -F "burn.num=500" \
       -F "mcmc.num=500" \
       -F "stg1.tr.type=Discrete" \
       -F "stg2.tr.type=Discrete" \
       -F "x.categorical=M" \
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

# CATE
jobidcate=`curl -s -X POST "https://pcats.research.cchmc.org/api/job/$jobid/dynamicgp.cate" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" \
       -F "x=M" \
       -F "control.tr=0,0" \
       -F "treat.tr=1,0" | jq -r .jobid`

echo "JobIDcate: $jobidcate"

status="Pending"

while [ "$status" == "Pending" ] ;
do
   status="`curl -s -X GET \"https://pcats.research.cchmc.org/api/job/$jobidcate/status\" -H  \"accept: application/json\" | jq -r .status`"
   sleep 1
done

if [ "$status" == "Done" ] ; then
   curl -s -X GET "https://pcats.research.cchmc.org/api/job/$jobidcate/print"
   echo ""
else
   echo "Unexpected status is $status" 
fi

