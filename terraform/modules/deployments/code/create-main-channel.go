package main

import (
	"encoding/json"
	"fmt"
	"hlf/internal/fabric"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
)

func extractCertFromFile(filename string) (string, error) {
	// Lê o arquivo
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		return "", fmt.Errorf("erro ao ler arquivo %s: %v", filename, err)
	}

	// Converte para string
	contentStr := string(content)

	// Encontra o início do certificado
	certStart := strings.Index(contentStr, "-----BEGIN CERTIFICATE-----")
	if certStart == -1 {
		return "", fmt.Errorf("certificado não encontrado no arquivo %s", filename)
	}

	// Encontra o fim do certificado
	certEnd := strings.Index(contentStr[certStart:], "-----END CERTIFICATE-----")
	if certEnd == -1 {
		return "", fmt.Errorf("fim do certificado não encontrado no arquivo %s", filename)
	}

	// Extrai o certificado completo
	cert := contentStr[certStart : certStart+certEnd+len("-----END CERTIFICATE-----")]
	
	return cert, nil
}

func main() {
	// Variáveis de ambiente opcionais
	channelName := os.Getenv("CHANNEL_NAME")
	if channelName == "" {
		channelName = "demo"
	}

	secretName := os.Getenv("SECRET_NAME")
	if secretName == "" {
		secretName = "wallet"
	}

	secretNamespace := os.Getenv("SECRET_NAMESPACE")
	if secretNamespace == "" {
		secretNamespace = "default"
	}

	// Lê o arquivo de configuração
	file, err := os.ReadFile("output.json")
	if err != nil {
		log.Fatalf("❌ Erro ao ler o JSON: %v", err)
	}

	var config fabric.Config
	if err := json.Unmarshal(file, &config); err != nil {
		log.Fatalf("❌ Erro ao fazer unmarshal do JSON: %v", err)
	}

	// Constrói as listas de MSP IDs
	var ordererMSPs []string
	var peerMSPs []string
	
	for _, ca := range config.CAs {
		if ca.UserType == "orderer" {
			ordererMSPs = append(ordererMSPs, ca.MspID)
		} else if ca.UserType == "peer" {
			peerMSPs = append(peerMSPs, ca.MspID)
		}
	}

	// Constrói a lista de identidades
	var identities []string
	for _, channel := range config.Channels {
		// Identidade principal
		identity := fmt.Sprintf("%s;%s", channel.MspID, channel.FileOutput)
		identities = append(identities, identity)
		
		// Identidade de assinatura/TLS
		if channel.FileOutputTls != "" {
			identityTls := fmt.Sprintf("%s-tls;%s", channel.MspID, channel.FileOutputTls)
			identities = append(identities, identityTls)
		}
		
		// Adiciona identidade de assinatura para orderer
		if strings.Contains(channel.MspID, "Orderer") {
			identitySign := fmt.Sprintf("%s-sign;%s", channel.MspID, strings.Replace(channel.FileOutput, ".yaml", "sign.yaml", 1))
			identities = append(identities, identitySign)
		}
	}

	// Constrói a lista de consenters
	var consenters []string
	for _, orderer := range config.Orderers {
		consenter := fmt.Sprintf("%s:%s", orderer.Hosts, orderer.IstioPort)
		consenters = append(consenters, consenter)
	}

	// Extrai o certificado TLS do orderer
	fmt.Println("🔍 Extraindo certificado TLS do orderer...")
	ordererCertFile := "orderermsp.yaml"
	for _, channel := range config.Channels {
		if strings.Contains(channel.MspID, "Orderer") && channel.FileOutput != "" {
			ordererCertFile = channel.FileOutput
			break
		}
	}

	cert, err := extractCertFromFile(ordererCertFile)
	if err != nil {
		log.Printf("⚠️  Aviso: não foi possível extrair o certificado: %v", err)
		// Continua sem o certificado, pode ser adicionado manualmente depois
	}

	// Salva o certificado em um arquivo temporário se foi extraído
	certFile := "/tmp/orderer-cert.pem"
	if cert != "" {
		err = ioutil.WriteFile(certFile, []byte(cert), 0644)
		if err != nil {
			log.Fatalf("❌ Erro ao salvar certificado: %v", err)
		}
		defer os.Remove(certFile) // Remove o arquivo temporário ao final
	}

	// Constrói o comando
	fmt.Printf("🔧 Criando o canal principal %s...\n", channelName)
	
	args := []string{
		"hlf", "channelcrd", "main", "create",
		"--name", channelName,
		"--channel-name", channelName,
		"--absolute-max-bytes", "1048576",
		"--max-message-count", "10",
		"--preferred-max-bytes", "524288",
		"--batch-timeout", "2s",
		"--etcd-raft-election-tick", "10",
		"--etcd-raft-heartbeat-tick", "1",
		"--etcd-raft-max-inflight-blocks", "5",
		"--etcd-raft-snapshot-interval-size", "16777216",
		"--etcd-raft-tick-interval", "500ms",
		"--secret-name", secretName,
		"--secret-ns", secretNamespace,
	}

	// Adiciona MSP IDs de admin
	for _, msp := range ordererMSPs {
		args = append(args, "--admin-orderer-orgs", msp)
		args = append(args, "--orderer-orgs", msp)
	}
	
	for _, msp := range peerMSPs {
		args = append(args, "--admin-peer-orgs", msp)
		args = append(args, "--peer-orgs", msp)
	}

	// Adiciona identidades
	for _, identity := range identities {
		args = append(args, "--identities", identity)
	}

	// Adiciona consenters
	for _, consenter := range consenters {
		args = append(args, "--consenters", consenter)
	}

	// Adiciona certificado se foi extraído
	if cert != "" {
		args = append(args, "--consenter-certificates", certFile)
	}

	// Adiciona flag de output para visualizar antes de aplicar
	// args = append(args, "--output")

	// Executa o comando
	cmd := exec.Command("kubectl", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Debug: imprime o comando completo
	fmt.Println("📋 Comando a ser executado:")
	fmt.Println("kubectl", strings.Join(args, " "))
	fmt.Println()

	if err := cmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao criar o canal principal: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("✅ Canal principal %s criado com sucesso.\n", channelName)
	fmt.Println()
	fmt.Println("💡 Para aplicar o canal, remova a flag --output e execute novamente.")
}
