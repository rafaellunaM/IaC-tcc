## To Do
* modulirize terraform
* create a way to edit paramaters of config on the terraform 
* deploy HLF
* paramateizer HLF
* configure HLF options from pkl file
* test installation
* create cluster k8s with ansible
* deploy HLF


## Start project
* rm terraform.tfstate # Because is deployment on the new account
* terraform apply -auto-approve
* export aws.env
* aws eks update-kubeconfig --region us-east-1 --name HLF_eks
* kubectl apply -f deployments/toolbox.yaml
* access toolbox pod  kubectl exec -it <pod> -- bash
* install on the toolbox bash-completion, helm, awscli 2, kubectl and you must export envs to aws cli (aws.env)
* inside toolbox container, install sh install-tools/install-tools.sh and has other scripts to install hlf path: /install-hlf
* Still has some errors with install-tools.sh when expor env vars, it must be done manually (copy env vars and execut aws eks add cluster)
* Apply istio and core-dns config before init toolbox container, can be done inside container, but should be to restart after

## Start with makefile
* make aws_provider
* make local_provider
