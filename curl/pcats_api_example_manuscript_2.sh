#!/bin/bash

jobid=`curl -s -X POST "https://pcats.research.cchmc.org/api/staticgp" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" \
       -F "data=@../data/example2.csv;type=text/csv" \
       -F "outcome=Y" \
       -F "treatment=A,Z" \
       -F "x.explanatory=X" \
       -F "x.confounding=X" \
       -F "tr.hte=Gender" \
       -F "tr.type=Discrete" \
       -F "tr2.values=-1,0,1" \
       -F "tr2.type=Continuous" \
       -F "burn.num=500" \
       -F "mcmc.num=500" \
       -F "seed=5000" \
       -F "outcome.type=Continuous" \
       -F "x.categorical=Gender" \
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
jobidcate=`curl -s -X POST "https://pcats.research.cchmc.org/api/job/$jobid/staticgp.cate" -H  "accept: application/json" -H  "Content-Type: multipart/form-data" \
       -F "x=Gender" \
       -F "control.tr=0,0" \
       -F "treat.tr=1,0" \
       -F "pr.values=0" | jq -r .jobid`

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

