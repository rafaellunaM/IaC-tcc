AWS_MAKEFILE = make -C terraform -f Makefile

aws_render: 
	pkl eval --env-var env_cluster=aws -f json config/cluster-environment.pkl > config/terraform.tfvars.json;

aws_apply:
	${AWS_MAKEFILE} aws_provider

aws_plan:
	${AWS_MAKEFILE} aws_plan

local_provider:
	pkl eval --env-var env_cluster=local -f json config/cluster-environment.pkl > config/terraform.tfvars.json; \
