## Sequence

* create-ca.go
* register-user-peers-cas.go
* register-user-orderes-cas.go
* deploy-peers.go
* deploy-orderer.go
* channel-ca-register.go

* channel-ca-enroll.go _ERRO 
* create-generic-wallet.go
* create-main-channel.go

### Depends on: https://github.com/rafaellunaM/IaC-tcc/blob/main/terraform/modules/deployments/code/output.json


# HLF deploy
go run create-cas.go && \ 
kubectl wait --timeout=60s --for=condition=Running fabriccas.hlf.kungfusoftware.es --all && \
go run register-user-peers-cas.go && \
go run register-user-orderes-cas.go && \
go run deploy-peers.go && \
go run deploy-orderer.go && \
go run channel-ca-register.go && \
go run channel-ca-enroll.go && \
kubectl delete secrets wallet && \
go run create-generic-wallet.go 

# secret
kubectl delete secrets wallet && \
go run create-generic-wallet.go 

# consulta
kubectl get secrete |grep wallet
watch kubectl get fabricmainchannels 
watch kubectl get pods

# delete
rm *.yaml
kubectl delete fabricorderernodes.hlf.kungfusoftware.es --all-namespaces --all
kubectl delete fabricpeers.hlf.kungfusoftware.es --all-namespaces --all
kubectl delete fabriccas.hlf.kungfusoftware.es --all-namespaces --all
kubectl delete fabricchaincode.hlf.kungfusoftware.es --all-namespaces --all
kubectl delete fabricmainchannels --all-namespaces --all
kubectl delete fabricfollowerchannels --all-namespaces --all
watch kubectl get pods
