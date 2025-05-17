
#!/bin/bash
set -e
echo "install bash-completion"
apt-get update && apt-get install -y bash-completion
echo "install curl"
apt install curl -y
echo "install git"
apt install git -y
echo "install Helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
echo "install AWS CLI v2"
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
echo "install kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
echo "configure eks"
mkdir -p ~/.aws

cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $(cat aws-vars/AWS_ACCESS_KEY_ID)
aws_secret_access_key = $(cat aws-vars/AWS_SECRET_ACCESS_KEY)
EOF

aws eks update-kubeconfig --region $(cat aws-vars/EKS_REGION) --name $(cat aws-vars/EKS_CLUSTER_NAME)
