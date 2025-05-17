#!/bin/bash
echo "Install a chaincode"
kubectl hlf inspect --output test-1.yaml -o Org1MSP -o OrdererMSP
kubectl hlf inspect --output test-2.yaml -o Org2MSP -o OrdererMSP

# Org1MSP  
kubectl hlf ca register --name=org1-ca --user=admin3 --secret=adminpw --type=admin \
--enroll-id enroll --enroll-secret=enrollpw --mspid Org1MSP  

kubectl hlf ca enroll --name=org1-ca --user=admin3 --secret=adminpw --mspid Org1MSP \
        --ca-name ca  --output test-peer-org-1.yaml

kubectl hlf utils adduser --userPath=test-peer-org-1.yaml --config=test-1.yaml --username=admin3 --mspid=Org1MSP

# Org2MSP
kubectl hlf ca register --name=org2-ca --user=admin3 --secret=adminpw --type=admin \
--enroll-id enroll --enroll-secret=enrollpw --mspid Org2MSP  

kubectl hlf ca enroll --name=org2-ca --user=admin3 --secret=adminpw --mspid Org2MSP \
        --ca-name ca  --output test-peer-org-2.yaml

kubectl hlf utils adduser --userPath=test-peer-org-2.yaml --config=test-2.yaml --username=admin3 --mspid=Org2MSP

echo "Create metadata file"
rm code.tar.gz chaincode.tgz
export CHAINCODE_NAME=asset
export CHAINCODE_LABEL=asset
cat << METADATA-EOF > "metadata.json"
{
    "type": "ccaas",
    "label": "${CHAINCODE_LABEL}"
}
METADATA-EOF

echo "Prepare connection file"
cat > "connection.json" <<CONN_EOF
{
  "address": "${CHAINCODE_NAME}:7052",
  "dial_timeout": "10s",
  "tls_required": false
}
CONN_EOF

tar cfz code.tar.gz connection.json
tar cfz chaincode.tgz metadata.json code.tar.gz
export PACKAGE_ID=$(kubectl hlf chaincode calculatepackageid --path=chaincode.tgz --language=node --label=$CHAINCODE_LABEL)
echo "PACKAGE_ID=$PACKAGE_ID"

# Install chaincode for peers from org1
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=test-1.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin3 --peer=org1-peer0.default
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=test-1.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin3 --peer=org1-peer2.default


# Install chaincode for peers from org2
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=test-2.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin3 --peer=org2-peer0.default
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=test-2.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin3 --peer=org2-peer2.default

# Deploy chaincode container on cluster
kubectl hlf externalchaincode sync --image=kfsoftware/chaincode-external:latest \
    --name=$CHAINCODE_NAME \
    --namespace=default \
    --package-id=$PACKAGE_ID \
    --tls-required=false \
    --replicas=1

# Check installed chaincodes
kubectl hlf chaincode queryinstalled --config=test-1.yaml --user=admin3 --peer=org1-peer0.default
kubectl hlf chaincode queryinstalled --config=test-1.yaml --user=admin3 --peer=org1-peer2.default

kubectl hlf chaincode queryinstalled --config=test-2.yaml --user=admin3 --peer=org2-peer0.default
kubectl hlf chaincode queryinstalled --config=test-2.yaml --user=admin3 --peer=org2-peer2.default

# Approve chaincode
export SEQUENCE=1
export VERSION="1.0"

# should be apply just a peer of org
# Approve chaincode to org1
kubectl hlf chaincode approveformyorg --config=test-1.yaml --user=admin3 --peer=org1-peer0.default \
    --package-id=$PACKAGE_ID --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="OR('Org1MSP.member', 'Org2MSP.member')" --channel=demo

# Approve chaincode to org2
kubectl hlf chaincode approveformyorg --config=test-2.yaml --user=admin3 --peer=org2-peer0.default \
    --package-id=$PACKAGE_ID --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="OR('Org1MSP.member', 'Org2MSP.member')" --channel=demoo

# Commit chaincode
kubectl hlf chaincode commit --config=test-1.yaml --user=admin3 --mspid=Org1MSP \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="OR('Org1MSP.member', 'Org2MSP.member')" --channel=demo

# Invoke a transaction on the channel 
kubectl hlf chaincode invoke --config=test-1.yaml \
    --user=admin3 --peer=org1-peer0.default \
    --chaincode=asset --channel=demo \
    --fcn=initLedger -a '[]'

# Query assets in the channel
# Query org-1
kubectl hlf chaincode query --config=test-1.yaml \
    --user=admin3 --peer=org1-peer0.default \
    --chaincode=asset --channel=demo \
    --fcn=GetAllAssets -a '[]'

# Query org-2
kubectl hlf chaincode query --config=test-2.yaml \
--user=admin3 --peer=org2-peer0.default \
--chaincode=asset --channel=demo \
--fcn=GetAllAssets -a '[]'
