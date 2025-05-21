package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	// Parâmetros fixos
	namespace := "default"
	caName := "org1-ca"
	user := "admin"
	secret := "adminpw"
	enrollID := "enroll"
	enrollSecret := "enrollpw"
	mspID := "Org1MSP"

	// 1. Registrar admin
	fmt.Println("🔐 Registrando o admin da org1 no CA...")
	registerCmd := exec.Command("kubectl", "hlf", "ca", "register",
		"--name="+caName,
		"--namespace="+namespace,
		"--user="+user,
		"--secret="+secret,
		"--type=admin",
		"--enroll-id="+enrollID,
		"--enroll-secret="+enrollSecret,
		"--mspid="+mspID,
	)
	registerCmd.Stdout = os.Stdout
	registerCmd.Stderr = os.Stderr
	if err := registerCmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao registrar admin: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("✅ Admin registrado com sucesso.")

	// 2. Enroll do admin
	fmt.Println("📥 Enroll do admin da org1...")
	enrollCmd := exec.Command("kubectl", "hlf", "ca", "enroll",
		"--name="+caName,
		"--namespace="+namespace,
		"--user="+user,
		"--secret="+secret,
		"--mspid="+mspID,
		"--ca-name=ca",
		"--output=org1msp.yaml",
	)
	enrollCmd.Stdout = os.Stdout
	enrollCmd.Stderr = os.Stderr
	if err := enrollCmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao fazer o enroll: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("✅ Enroll realizado com sucesso (org1msp.yaml).")

	// 3. Criar identidade no cluster
	fmt.Println("🧾 Criando identidade kubernetes (org1-admin)...")
	createIdentityCmd := exec.Command("kubectl", "hlf", "identity", "create",
		"--name=org1-admin",
		"--namespace="+namespace,
		"--ca-name="+caName,
		"--ca-namespace="+namespace,
		"--ca=ca",
		"--mspid="+mspID,
		"--enroll-id="+user,
		"--enroll-secret="+secret,
	)
	createIdentityCmd.Stdout = os.Stdout
	createIdentityCmd.Stderr = os.Stderr
	if err := createIdentityCmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao criar identidade: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("✅ Identidade org1-admin criada com sucesso.")
}
