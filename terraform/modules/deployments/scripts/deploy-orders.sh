#!/bin/bash
echo "registrar usuário do order"
kubectl hlf ca register --name=ord-ca --user=orderer --secret=ordererpw \
    --type=orderer --enroll-id enroll --enroll-secret=enrollpw --mspid=OrdererMSP --ca-url="https://ord-ca.localho.st:443"

echo "Deploy orderer"
kubectl hlf ordnode create --image=$ORDERER_IMAGE --version=$ORDERER_VERSION \
    --storage-class=$SC_NAME --enroll-id=orderer --mspid=OrdererMSP \
    --enroll-pw=ordererpw --capacity=2Gi --name=ord-node1 --ca-name=ord-ca.default \
    --hosts=orderer0-ord.localho.st --admin-hosts=admin-orderer0-ord.localho.st --istio-port=443


kubectl hlf ordnode create --image=$ORDERER_IMAGE --version=$ORDERER_VERSION \
    --storage-class=$SC_NAME --enroll-id=orderer --mspid=OrdererMSP \
    --enroll-pw=ordererpw --capacity=2Gi --name=ord-node2 --ca-name=ord-ca.default \
    --hosts=orderer1-ord.localho.st --admin-hosts=admin-orderer1-ord.localho.st --istio-port=443


kubectl hlf ordnode create --image=$ORDERER_IMAGE --version=$ORDERER_VERSION \
    --storage-class=$SC_NAME --enroll-id=orderer --mspid=OrdererMSP \
    --enroll-pw=ordererpw --capacity=2Gi --name=ord-node3 --ca-name=ord-ca.default \
    --hosts=orderer2-ord.localho.st --admin-hosts=admin-orderer2-ord.localho.st --istio-port=443


kubectl hlf ordnode create --image=$ORDERER_IMAGE --version=$ORDERER_VERSION \
    --storage-class=$SC_NAME --enroll-id=orderer --mspid=OrdererMSP \
    --enroll-pw=ordererpw --capacity=2Gi --name=ord-node4 --ca-name=ord-ca.default \
    --hosts=orderer3-ord.localho.st --admin-hosts=admin-orderer3-ord.localho.st --istio-port=443
