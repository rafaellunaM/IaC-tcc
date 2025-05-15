create_values:
	@if [ -f ../config/aws.env ]; then \
		pkl eval --env-var env_cluster=aws -f json ../config/cluster-environment.pkl > ../config/terraform.tfvars.json; \
		echo "create terraform.tfvars.json"; \
	else \
		echo "Not found config/aws.env with AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"; \
		exit 1; \
	fi

aws_render:
	pkl eval --env-var env_cluster=aws -f json ../config/cluster-environment.pkl > ../config/terraform.tfvars.json;

aws_apply: create_values
	terraform init
	terraform apply -auto-approve -var-file=../config/terraform.tfvars.json

aws_plan: create_values
	terraform init 
	terraform	plan -var-file=../config/terraform.tfvars.json

