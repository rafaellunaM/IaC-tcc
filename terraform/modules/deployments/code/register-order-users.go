package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {
    // Define os parâmetros
    caName := "ord-ca"
    user := "orderer"
    secret := "ordererpw"
    userType := "orderer"
    enrollID := "enroll"
    enrollSecret := "enrollpw"
    mspID := "OrdererMSP"
    caURL := "https://ord-ca.localho.st:443"

    // Monta o comando
    cmd := exec.Command("kubectl", "hlf", "ca", "register",
        "--name="+caName,
        "--user="+user,
        "--secret="+secret,
        "--type="+userType,
        "--enroll-id="+enrollID,
        "--enroll-secret="+enrollSecret,
        "--mspid="+mspID,
        "--ca-url="+caURL,
    )

    // Redireciona saída para o terminal
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    // Executa o comando
    fmt.Println("🔐 Registrando o orderer...")
    if err := cmd.Run(); err != nil {
        fmt.Printf("❌ Erro ao registrar o orderer: %v\n", err)
        os.Exit(1)
    }

    fmt.Println("✅ Orderer registrado com sucesso.")
}
