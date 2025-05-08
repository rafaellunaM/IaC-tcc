RENDER_TFVARS: pkl eval -f json eks-vars.pkl > terraform.tfvars.json

render:
	$(RENDER_TFVARS)
