    #!/bin/bash
    echo "Create channel"
    # Register and enrolling OrdererMSP identity
    kubectl hlf ca register --name=ord-ca --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=OrdererMSP
    kubectl hlf ca enroll --name=ord-ca --namespace=default --user=admin --secret=adminpw --mspid OrdererMSP --ca-name tlsca  --output orderermsp.yaml  
    kubectl hlf ca enroll --name=ord-ca --namespace=default --user=admin --secret=adminpw --mspid OrdererMSP --ca-name ca  --output orderermspsign.yaml

    echo "Register and enrolling Org1MSP Orderer identity"
    kubectl hlf ca register --name=org1-ca --user=admin --secret=adminpw --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org1MSP
    kubectl hlf ca enroll --name=org1-ca --namespace=default --user=admin --secret=adminpw --mspid Org1MSP --ca-name tlsca  --output org1msp-tlsca.yaml

    echo "Register and enrolling Org2MSP Orderer identity"
    kubectl hlf ca register --name=org2-ca --user=admin2 --secret=adminpw --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org2MSP
    kubectl hlf ca enroll --name=org2-ca --namespace=default --user=admin2 --secret=adminpw --mspid Org2MSP --ca-name tlsca  --output org2msp-tlsca.yaml

    # Register and enrolling Org1MSP identity
    kubectl hlf ca register --name=org1-ca --namespace=default --user=admin --secret=adminpw --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org1MSP
    kubectl hlf ca register --name=org2-ca --namespace=default --user=admin2 --secret=adminpw --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org2MSP

    kubectl hlf ca enroll --name=org1-ca --namespace=default --user=admin --secret=adminpw --mspid Org1MSP --ca-name ca  --output org1msp.yaml
    kubectl hlf ca enroll --name=org2-ca --namespace=default --user=admin2 --secret=adminpw --mspid Org2MSP --ca-name ca  --output org2msp.yaml

    kubectl hlf identity create --name org1-admin --namespace default --ca-name org1-ca --ca-namespace default --ca ca --mspid Org1MSP --enroll-id admin --enroll-secret adminpw
    kubectl hlf identity create --name org2-admin --namespace default --ca-name org2-ca --ca-namespace default --ca ca --mspid Org2MSP --enroll-id admin2 --enroll-secret adminpw

    # Create the secret
    kubectl create secret generic wallet --namespace=default \
            --from-file=org1msp.yaml=$PWD/org1msp.yaml \
            --from-file=org2msp.yaml=$PWD/org2msp.yaml \
            --from-file=orderermsp.yaml=$PWD/orderermsp.yaml \
            --from-file=orderermspsign.yaml=$PWD/orderermspsign.yaml
