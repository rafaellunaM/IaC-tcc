package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {
    // Define os parâmetros
    caName := "org1-ca"
    user := "peer"
    secret := "peerpw"
    userType := "peer"
    enrollID := "enroll"
    enrollSecret := "enrollpw"
    mspID := "Org1MSP"

    // Monta o comando
    cmd := exec.Command("kubectl", "hlf", "ca", "register",
        "--name="+caName,
        "--user="+user,
        "--secret="+secret,
        "--type="+userType,
        "--enroll-id="+enrollID,
        "--enroll-secret="+enrollSecret,
        "--mspid="+mspID,
    )

    // Redireciona saída para o console
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    // Executa o comando
    if err := cmd.Run(); err != nil {
        fmt.Printf("Erro ao registrar identidade: %v\n", err)
        os.Exit(1)
    }

    fmt.Println("Identidade registrada com sucesso.")
}
