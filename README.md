## Depends on:
* `awscli`
* `terraform`
* `pkl language`
* `kubectl`
* `https://github.com/rafaellunaM/hlf-module-tcc`

## Get started
* create file config/aws.env with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* `aws eks update-kubeconfig --region us-east-1 --name HLF_eks`
* `make aws_provider`
* `make hlf_access`
* you can set ord nodes and peers nodes numbers and anothers configurations in the hlf/set-hlf.pkl
* `make hlf_render` 

## Start with aws provider
* `make aws_provider`

## Start with k3s
* `make local_provider`
