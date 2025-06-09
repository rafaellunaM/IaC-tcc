AWS_MAKEFILE = make -C terraform -f Makefile

aws_render: 
	$(AWS_MAKEFILE) aws_render

aws_apply:
	${AWS_MAKEFILE} aws_apply

aws_plan:
	${AWS_MAKEFILE} aws_plan

local_provider:
	pkl eval --env-var env_cluster=local -f json config/cluster-environment.pkl > config/terraform.tfvars.json; \

hlf_render:
	pkl eval -f json hlf/hlf-config.pkl > terraform/modules/deployments/files/hlf-config.json

hlf_access:
	kubectl exec -it pods/hlf-toolbox-deployment-0 -- bash -c "cd hlf-module-tcc && exec bash"

# kubectl exec -it pods/hlf-toolbox-deployment-0 -- bash -c "go run -C hlf-module-tcc main.go"