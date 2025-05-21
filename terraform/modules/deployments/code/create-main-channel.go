package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// getIndentedCert recebe resource como duas strings: tipo e nome do recurso
func getIndentedCert(resourceType, resourceName, jsonPath string) (string, error) {
	cmd := exec.Command("kubectl", "get", resourceType, resourceName, "-o", "jsonpath="+jsonPath)
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	// Adiciona 8 espaços antes de cada linha para indentação YAML
	lines := strings.Split(string(output), "\n")
	for i := range lines {
		lines[i] = "        " + lines[i]
	}
	return strings.Join(lines, "\n"), nil
}

func main() {
	fmt.Println("📄 Coletando certificados...")

	orderer0TLS, err0 := getIndentedCert("fabricorderernodes", "ord-node1", "{.status.tlsCert}")
	orderer1TLS, err1 := getIndentedCert("fabricorderernodes", "ord-node2", "{.status.tlsCert}")
	orderer2TLS, err2 := getIndentedCert("fabricorderernodes", "ord-node3", "{.status.tlsCert}")
	orderer3TLS, err3 := getIndentedCert("fabricorderernodes", "ord-node4", "{.status.tlsCert}")

	if err0 != nil || err1 != nil || err2 != nil || err3 != nil {
		fmt.Printf("❌ Erros ao pegar TLS certs dos orderers:\n")
		if err0 != nil {
			fmt.Printf("  orderer0: %v\n", err0)
		}
		if err1 != nil {
			fmt.Printf("  orderer1: %v\n", err1)
		}
		if err2 != nil {
			fmt.Printf("  orderer2: %v\n", err2)
		}
		if err3 != nil {
			fmt.Printf("  orderer3: %v\n", err3)
		}
		os.Exit(1)
	}

	// Monta o YAML
	yaml := fmt.Sprintf(`apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricMainChannel
metadata:
  name: demo
spec:
  name: demo
  adminOrdererOrganizations:
    - mspID: OrdererMSP
  adminPeerOrganizations:
    - mspID: Org1MSP
  channelConfig:
    application:
      acls: null
      capabilities:
        - V2_0
        - V2_5
      policies: null
    capabilities:
      - V2_0
    orderer:
      batchSize:
        absoluteMaxBytes: 1048576
        maxMessageCount: 10
        preferredMaxBytes: 524288
      batchTimeout: 2s
      capabilities:
        - V2_0
      etcdRaft:
        options:
          electionTick: 10
          heartbeatTick: 1
          maxInflightBlocks: 5
          snapshotIntervalSize: 16777216
          tickInterval: 500ms
      ordererType: etcdraft
      policies: null
      state: STATE_NORMAL
    policies: null
  externalOrdererOrganizations: []
  externalPeerOrganizations: []
  peerOrganizations:
    - mspID: Org1MSP
      caName: "org1-ca"
      caNamespace: "default"
  identities:
    OrdererMSP:
      secretKey: orderermsp.yaml
      secretName: wallet
      secretNamespace: default
    OrdererMSP-tls:
      secretKey: orderermsp.yaml
      secretName: wallet
      secretNamespace: default
    OrdererMSP-sign:
      secretKey: orderermspsign.yaml
      secretName: wallet
      secretNamespace: default
    Org1MSP:
      secretKey: org1msp.yaml
      secretName: wallet
      secretNamespace: default
  ordererOrganizations:
    - caName: "ord-ca"
      caNamespace: "default"
      externalOrderersToJoin:
        - host: ord-node1.default
          port: 7053
        - host: ord-node2.default
          port: 7053
        - host: ord-node3.default
          port: 7053
        - host: ord-node4.default
          port: 7053
      mspID: OrdererMSP
      ordererEndpoints:
        - orderer0-ord.localho.st:443
        - orderer1-ord.localho.st:443
        - orderer2-ord.localho.st:443
        - orderer3-ord.localho.st:443
      orderersToJoin: []
  orderers:
    - host: orderer0-ord.localho.st
      port: 443
      tlsCert: |-
%s
    - host: orderer1-ord.localho.st
      port: 443
      tlsCert: |-
%s
    - host: orderer2-ord.localho.st
      port: 443
      tlsCert: |-
%s
    - host: orderer3-ord.localho.st
      port: 443
      tlsCert: |-
%s
`, orderer0TLS, orderer1TLS, orderer2TLS, orderer3TLS)

	fmt.Println("📤 Aplicando recurso FabricMainChannel...")

	applyCmd := exec.Command("kubectl", "apply", "-f", "-")
	applyCmd.Stdin = bytes.NewBufferString(yaml)
	applyCmd.Stdout = os.Stdout
	applyCmd.Stderr = os.Stderr

	if err := applyCmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao aplicar canal: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("✅ Canal 'demo' criado com sucesso.")
}
