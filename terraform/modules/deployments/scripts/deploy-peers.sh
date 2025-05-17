#!/bin/bash
echo "registrar usuário para  HLF-Peer"
kubectl hlf ca register --name=org1-ca --user=peer1 --secret=peerpw --type=peer --enroll-id enroll --enroll-secret=enrollpw --mspid Org1MSP
kubectl hlf ca register --name=org1-ca --user=peer2 --secret=peerpw --type=peer --enroll-id enroll --enroll-secret=enrollpw --mspid Org1MSP

kubectl hlf ca register --name=org2-ca --user=peer1 --secret=peerpw --type=peer --enroll-id enroll --enroll-secret=enrollpw --mspid Org2MSP
kubectl hlf ca register --name=org2-ca --user=peer2 --secret=peerpw --type=peer --enroll-id enroll --enroll-secret=enrollpw --mspid Org2MSP

echo "criar peers"
echo "criar peer para org-1"
kubectl hlf peer create --statedb=leveldb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=$SC_NAME --enroll-id=peer1 --mspid=Org1MSP \
    --enroll-pw=peerpw --capacity=5Gi --name=org1-peer1 --ca-name=org1-ca.default \
    --hosts=peer0-org1.localho.st --istio-port=443
kubectl hlf peer create --statedb=leveldb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=$SC_NAME --enroll-id=peer2 --mspid=Org1MSP \
    --enroll-pw=peerpw --capacity=5Gi --name=org1-peer2 --ca-name=org1-ca.default \
    --hosts=peer2-org1.localho.st --istio-port=443

echo "criar peer para org-2"
kubectl hlf peer create --statedb=leveldb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=$SC_NAME --enroll-id=peer1 --mspid=Org2MSP \
    --enroll-pw=peerpw --capacity=5Gi --name=org2-peer1 --ca-name=org2-ca.default \
    --hosts=peer0-org2.localho.st --istio-port=443

kubectl hlf peer create --statedb=leveldb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=$SC_NAME --enroll-id=peer2 --mspid=Org2MSP \
    --enroll-pw=peerpw --capacity=5Gi --name=org2-peer2 --ca-name=org2-ca.default \
    --hosts=peer2-org2.localho.st --istio-port=443
