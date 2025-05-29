
#!/bin/bash
# To Do: Create a docker image with this layer
set -e

apt-get update && apt-get install -y bash-completion
apt install curl -y
apt install wget -y
apt install git -y
git clone https://github.com/rafaellunaM/hlf-module-tcc.git /home/hlf-module-tcc
wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
# adjust to export to another terminal
export PATH=$PATH:/usr/local/go/bin
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $(cat aws-vars/AWS_ACCESS_KEY_ID)
aws_secret_access_key = $(cat aws-vars/AWS_SECRET_ACCESS_KEY)
EOF

aws eks update-kubeconfig --region $(cat aws-vars/EKS_REGION) --name $(cat aws-vars/EKS_CLUSTER_NAME)
