creat_values:
	@if [ -f ./aws.env ]; then \
		pkl eval --env-var env_cluster=aws -f json cluster-environment.pkl > terraform.tfvars.json; \
		echo "create terraform.tfvars.json"; \
	else \
		echo "Not found aws.env with AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"; \
		exit 1; \
	fi

aws_provider: creat_values
	terraform apply -auto-approve --target=aws_eks_node_group.eks_nodes[0]
	terraform apply -auto-approve

local_provider:
	pkl eval --env-var env_cluster=local -f json cluster-environment.pkl > terraform.tfvars.json; \
