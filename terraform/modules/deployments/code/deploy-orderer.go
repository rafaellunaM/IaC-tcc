package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {
    // Recupera variáveis de ambiente
    ordererImage := os.Getenv("ORDERER_IMAGE")
    ordererVersion := os.Getenv("ORDERER_VERSION")
    storageClass := os.Getenv("SC_NAME")

    if ordererImage == "" || ordererVersion == "" || storageClass == "" {
        fmt.Println("Erro: ORDERER_IMAGE, ORDERER_VERSION e SC_NAME devem estar definidas nas variáveis de ambiente.")
        os.Exit(1)
    }

    // Função auxiliar para criar um nó orderer
    createOrderer := func(idx int) error {
        name := fmt.Sprintf("ord-node%d", idx)
        host := fmt.Sprintf("orderer%d-ord.localho.st", idx-1)
        adminHost := fmt.Sprintf("admin-orderer%d-ord.localho.st", idx-1)

        fmt.Printf("🔧 Criando %s...\n", name)
        cmd := exec.Command("kubectl", "hlf", "ordnode", "create",
            "--image="+ordererImage,
            "--version="+ordererVersion,
            "--storage-class="+storageClass,
            "--enroll-id=orderer",
            "--mspid=OrdererMSP",
            "--enroll-pw=ordererpw",
            "--capacity=2Gi",
            "--name="+name,
            "--ca-name=ord-ca.default",
            "--hosts="+host,
            "--admin-hosts="+adminHost,
            "--istio-port=443",
        )
        cmd.Stdout = os.Stdout
        cmd.Stderr = os.Stderr
        return cmd.Run()
    }

    // Cria os 4 nós
    for i := 1; i <= 4; i++ {
        if err := createOrderer(i); err != nil {
            fmt.Printf("❌ Erro ao criar ord-node%d: %v\n", i, err)
            os.Exit(1)
        }
        fmt.Printf("✅ ord-node%d criado com sucesso.\n", i)
    }

    // Aguarda todos ficarem em Running
    fmt.Println("⏳ Aguardando todos os orderer nodes ficarem em estado Running...")
    waitCmd := exec.Command("kubectl", "wait",
        "--timeout=180s",
        "--for=condition=Running",
        "fabricorderernodes.hlf.kungfusoftware.es",
        "--all",
    )
    waitCmd.Stdout = os.Stdout
    waitCmd.Stderr = os.Stderr
    if err := waitCmd.Run(); err != nil {
        fmt.Printf("❌ Erro ao aguardar orderer nodes: %v\n", err)
        os.Exit(1)
    }
    fmt.Println("✅ Todos os orderer nodes estão em execução.")
}
