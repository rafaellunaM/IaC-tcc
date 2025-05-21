package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	// Parâmetros fixos
	caName := "ord-ca"
	namespace := "default"
	user := "admin"
	secret := "adminpw"
	enrollID := "enroll"
	enrollSecret := "enrollpw"
	mspID := "OrdererMSP"

	// 1. Registrar admin
	fmt.Println("🔐 Registrando o admin no CA...")
	registerCmd := exec.Command("kubectl", "hlf", "ca", "register",
		"--name="+caName,
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

	// 2. Enroll para TLSCA
	fmt.Println("📥 Realizando o enroll do admin (TLSCA)...")
	enrollTLSCmd := exec.Command("kubectl", "hlf", "ca", "enroll",
		"--name="+caName,
		"--namespace="+namespace,
		"--user="+user,
		"--secret="+secret,
		"--mspid="+mspID,
		"--ca-name=tlsca",
		"--output=orderermsp.yaml",
	)
	enrollTLSCmd.Stdout = os.Stdout
	enrollTLSCmd.Stderr = os.Stderr
	if err := enrollTLSCmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao fazer enroll (TLS): %v\n", err)
		os.Exit(1)
	}
	fmt.Println("✅ Enroll TLS realizado com sucesso (orderermsp.yaml).")

	// 3. Enroll para CA
	fmt.Println("📥 Realizando o enroll do admin (CA)...")
	enrollSignCmd := exec.Command("kubectl", "hlf", "ca", "enroll",
		"--name="+caName,
		"--namespace="+namespace,
		"--user="+user,
		"--secret="+secret,
		"--mspid="+mspID,
		"--ca-name=ca",
		"--output=orderermspsign.yaml",
	)
	enrollSignCmd.Stdout = os.Stdout
	enrollSignCmd.Stderr = os.Stderr
	if err := enrollSignCmd.Run(); err != nil {
		fmt.Printf("❌ Erro ao fazer enroll (CA): %v\n", err)
		os.Exit(1)
	}
	fmt.Println("✅ Enroll CA realizado com sucesso (orderermspsign.yaml).")
}
