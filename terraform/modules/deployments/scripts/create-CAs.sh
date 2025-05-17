#!/bin/bash
echo "deploy HLF-CA"
kubectl hlf ca create  --image=$CA_IMAGE --version=$CA_VERSION --storage-class=ebs-csi-sc --capacity=1Gi --name=org1-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org1-ca.localho.st --istio-port=443

kubectl hlf ca create  --image=$CA_IMAGE --version=$CA_VERSION --storage-class=ebs-csi-sc --capacity=1Gi --name=org2-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org2-ca.localho.st --istio-port=443

kubectl hlf ca create  --image=$CA_IMAGE --version=$CA_VERSION --storage-class=ebs-csi-sc --capacity=1Gi --name=ord-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=ord-ca.localho.st --istio-port=443
