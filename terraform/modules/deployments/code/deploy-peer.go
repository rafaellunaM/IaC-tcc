package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {
    // Recupera variáveis de ambiente necessárias
    peerImage := os.Getenv("PEER_IMAGE")
    peerVersion := os.Getenv("PEER_VERSION")
    storageClass := os.Getenv("SC_NAME")

    // Verifica se variáveis estão definidas
    if peerImage == "" || peerVersion == "" || storageClass == "" {
        fmt.Println("Erro: PEER_IMAGE, PEER_VERSION e SC_NAME devem estar definidas nas variáveis de ambiente.")
        os.Exit(1)
    }

    // 1. Criação do Peer
    createCmd := exec.Command("kubectl", "hlf", "peer", "create",
        "--statedb=leveldb",
        "--image="+peerImage,
        "--version="+peerVersion,
        "--storage-class="+storageClass,
        "--enroll-id=peer",
        "--mspid=Org1MSP",
        "--enroll-pw=peerpw",
        "--capacity=5Gi",
        "--name=org1-peer0",
        "--ca-name=org1-ca.default",
        "--hosts=peer0-org1.localho.st",
        "--istio-port=443",
    )

    createCmd.Stdout = os.Stdout
    createCmd.Stderr = os.Stderr

    fmt.Println("🔧 Criando o peer org1-peer0...")
    if err := createCmd.Run(); err != nil {
        fmt.Printf("❌ Erro ao criar o peer: %v\n", err)
        os.Exit(1)
    }
    fmt.Println("✅ Peer criado com sucesso.")

    // 2. Espera até que o peer esteja em execução
    waitCmd := exec.Command("kubectl", "wait",
        "--timeout=180s",
        "--for=condition=Running",
        "fabricpeers.hlf.kungfusoftware.es",
        "--all",
    )

    waitCmd.Stdout = os.Stdout
    waitCmd.Stderr = os.Stderr
		// Remove this wait
    fmt.Println("⏳ Aguardando o peer ficar em estado Running...")
    if err := waitCmd.Run(); err != nil {
        fmt.Printf("❌ Erro ao esperar o peer: %v\n", err)
        os.Exit(1)
    }
    fmt.Println("✅ Todos os peers estão em execução.")
}
