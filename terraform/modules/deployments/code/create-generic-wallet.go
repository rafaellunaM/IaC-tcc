package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	namespace := "default"
	secretName := "wallet"
	pwd, err := os.Getwd()
	if err != nil {
		fmt.Printf("❌ Erro ao obter diretório atual: %v\n", err)
		os.Exit(1)
	}

	org1MSP := fmt.Sprintf("%s/org1msp.yaml", pwd)
	ordererMSP := fmt.Sprintf("%s/orderermsp.yaml", pwd)
	ordererSignMSP := fmt.Sprintf("%s/orderermspsign.yaml", pwd)

	fmt.Println("🔐 Criando Secret 'wallet' com os arquivos MSP...")
	cmd := exec.Command("kubectl", "create", "secret", "generic", secretName,
		"--namespace="+namespace,
		"--from-file=org1msp.yaml="+org1MSP,
		"--from-file=orderermsp.yaml="+ordererMSP,
		"--from-file=orderermspsign.yaml="+ordererSignMSP,
	)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao criar secret: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("✅ Secret 'wallet' criado com sucesso.")
}
