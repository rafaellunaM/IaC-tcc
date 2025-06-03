#!/bin/bash
set -e
mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $(cat aws-vars/AWS_ACCESS_KEY_ID)
aws_secret_access_key = $(cat aws-vars/AWS_SECRET_ACCESS_KEY)
EOF

aws eks update-kubeconfig --region $(cat aws-vars/EKS_REGION) --name $(cat aws-vars/EKS_CLUSTER_NAME)
