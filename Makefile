aws_provider = aws
local_provider = local

aws_provider:
	pkl eval --env-var env_cluster=$(aws_provider) -f json cluster-environment.pkl > terraform.tfvars.json

local_provider:
	pkl eval --env-var env_cluster=$(local_provider) -f json cluster-environment.pkl 
