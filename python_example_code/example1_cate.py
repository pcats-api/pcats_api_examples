#CATE

jobid_cate=pcats_api.staticgp_cate(jobid=jobid,
        x="RF_pos",
        control_tr="0",
        treat_tr="1",
        pr_values="5,10,15")

print("CATE JobID: {}".format(jobid_cate))

status=pcats_api.wait_for_result(jobid_cate)

if status=="Done":
    print(pcats_api.printgp(jobid_cate))
else:
    print("Error")
