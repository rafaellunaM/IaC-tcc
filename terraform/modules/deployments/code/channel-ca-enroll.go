package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
)

type Channels struct {
	Name          string `json:"name"`
	UserAdmin     string `json:"userAdmin"`
	Secretadmin   string `json:"secretadmin"`
	UserType      string `json:"userType"`
	EnrollID      string `json:"enrollId"`
	EnrollPW      string `json:"enrollPw"`
	MPSID         string `json:"mspID"`
	Namespace     string `json:"namespace"`
	CaNameTls     string `json:"caNameTls"`
	CaName        string `json:"caName"`
	FileOutput    string `json:"fileOutput"`
	FileOutputTls string `json:"fileOutputTls"`
}

type FullResources struct {
	Channels []Channels `json:"Channel"`
}

func main() {
	file, err := os.ReadFile("output.json")
	if err != nil {
		log.Fatalf("❌ Erro ao ler o JSON: %v", err)
	}

	var config FullResources
	if err := json.Unmarshal(file, &config); err != nil {
		log.Fatalf("❌ Erro ao fazer unmarshal do JSON: %v", err)
	}

	// Primeiro loop: enroll com tlsca (para TLS)
	for _, channels := range config.Channels {
		var outputFile string
		if channels.Name == "ord-ca" {
			outputFile = "orderermsp.yaml" // ord-ca + tlsca = orderermsp.yaml
		} else if channels.Name == "org1-ca" {
			outputFile = "org1msp-tlsca.yaml" // org1-ca + tlsca = org1msp-tlsca.yaml
		} else {
			outputFile = channels.FileOutput // fallback
		}

		fmt.Printf("🔧 Fazendo enroll TLS para %s -> %s...\n", channels.Name, outputFile)
		cmd := exec.Command("kubectl", "hlf", "ca", "enroll",
			"--name="+channels.Name,
			"--namespace="+channels.Namespace,
			"--user="+channels.UserAdmin,
			"--secret="+channels.Secretadmin,
			"--mspid="+channels.MPSID,
			"--ca-name="+channels.CaNameTls, // tlsca
			"--output="+outputFile,
		)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		if err := cmd.Run(); err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				exitCode := exitErr.ExitCode()
				if exitCode == 74 {
					fmt.Printf("⚠️ Identidade TLS %s já foi feito enroll, continuando...\n", channels.UserAdmin)
					continue
				}
				fmt.Printf("⚠️ Comando TLS retornou código de saída %d\n", exitCode)
			}
			fmt.Printf("❌ Erro ao fazer enroll TLS do usuário %s: %v\n", channels.Name, err)
			continue
		}
		fmt.Printf("✅ Enroll TLS concluído para %s -> %s\n", channels.Name, outputFile)
	}

	for _, channels := range config.Channels {
		var outputFile string
		if channels.Name == "ord-ca" {
			outputFile = "orderermspsign.yaml"
		} else if channels.Name == "org1-ca" {
			outputFile = "org1msp.yaml"
		} else {
			outputFile = channels.FileOutputTls
		}

		fmt.Printf("🔧 Fazendo enroll CA (signing) para %s -> %s...\n", channels.Name, outputFile)
		cmd := exec.Command("kubectl", "hlf", "ca", "enroll",
			"--name="+channels.Name,
			"--namespace="+channels.Namespace,
			"--user="+channels.UserAdmin,
			"--secret="+channels.Secretadmin,
			"--mspid="+channels.MPSID,
			"--ca-name="+channels.CaName,
			"--output="+outputFile,
		)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		if err := cmd.Run(); err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				exitCode := exitErr.ExitCode()
				if exitCode == 74 {
					fmt.Printf("⚠️ Identidade CA %s já foi feito enroll, continuando...\n", channels.UserAdmin)
					continue
				}
				fmt.Printf("⚠️ Comando CA retornou código de saída %d\n", exitCode)
			}
			fmt.Printf("❌ Erro ao fazer enroll CA do usuário %s: %v\n", channels.Name, err)
			continue
		}
		fmt.Printf("✅ Enroll CA concluído para %s -> %s\n", channels.Name, outputFile)
	}

	fmt.Println("🎉 Processo de enroll concluído!")
}
