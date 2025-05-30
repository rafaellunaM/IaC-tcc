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
	pkl eval -f json hlf/set-hlf.pkl > terraform/modules/deployments/files/hlf-config.json
