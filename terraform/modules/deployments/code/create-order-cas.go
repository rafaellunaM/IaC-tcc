package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {
    // Recupera variáveis de ambiente
    caImage := os.Getenv("CA_IMAGE")
    caVersion := os.Getenv("CA_VERSION")
    storageClass := os.Getenv("SC_NAME")

    if caImage == "" || caVersion == "" || storageClass == "" {
        fmt.Println("Erro: CA_IMAGE, CA_VERSION e SC_NAME devem estar definidas nas variáveis de ambiente.")
        os.Exit(1)
    }

    // 1. Cria a CA
    createCmd := exec.Command("kubectl", "hlf", "ca", "create",
        "--image="+caImage,
        "--version="+caVersion,
        "--storage-class="+storageClass,
        "--capacity=1Gi",
        "--name=ord-ca",
        "--enroll-id=enroll",
        "--enroll-pw=enrollpw",
        "--hosts=ord-ca.localho.st",
        "--istio-port=443",
    )
    createCmd.Stdout = os.Stdout
    createCmd.Stderr = os.Stderr

    fmt.Println("🔧 Criando a CA ord-ca...")
    if err := createCmd.Run(); err != nil {
        fmt.Printf("❌ Erro ao criar a CA: %v\n", err)
        os.Exit(1)
    }
    fmt.Println("✅ CA criada com sucesso.")

    // 2. Aguarda condição Running para todas as CAs
    waitCmd := exec.Command("kubectl", "wait",
        "--timeout=180s",
        "--for=condition=Running",
        "fabriccas.hlf.kungfusoftware.es",
        "--all",
    )
    waitCmd.Stdout = os.Stdout
    waitCmd.Stderr = os.Stderr
		// remove this wait
    fmt.Println("⏳ Aguardando CAs ficarem em estado Running...")
    if err := waitCmd.Run(); err != nil {
        fmt.Printf("❌ Erro ao aguardar as CAs: %v\n", err)
        os.Exit(1)
    }
    fmt.Println("✅ Todas as CAs estão em execução.")
}
