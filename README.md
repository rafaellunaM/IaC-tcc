## Depends on:
* awscli
* terraform
* pkl language
* kubectl

## Start project
* create file config/aws.env with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* `aws eks update-kubeconfig --region us-east-1 --name HLF_eks`
* `make aws_provider`
* `make hlf_access`

## Start with aws provider
* `make aws_provider`
* `make local_provider`
