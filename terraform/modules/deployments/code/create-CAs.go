package main

import (
    "fmt"
    "os"
    "os/exec"
)

func main() {

    file, err := os.ReadFile("test-b.json")
    var config FullResources

	err = json.Unmarshal(file, &config)
	if err != nil {
			log.Fatalf("Unable to marshal JSON due to %s", err)
	}

	 litter.Dump(config)

    caImage := os.Getenv("CA_IMAGE")
    caVersion := os.Getenv("CA_VERSION")
    scName := os.Getenv("SC_NAME")

    if caImage == "" || caVersion == "" || scName == "" {
        fmt.Println("Erro: CA_IMAGE, CA_VERSION e SC_NAME devem estar definidas nas variáveis de ambiente")
        os.Exit(1)
    }

    cmd := exec.Command("kubectl", "hlf", "ca", "create",
        "--image="+caImage,
        "--version="+caVersion,
        "--storage-class="+scName,
        "--capacity=1Gi",
        "--name=org1-ca",
        "--enroll-id=enroll",
        "--enroll-pw=enrollpw",
        "--hosts=org1-ca.localho.st",
        "--istio-port=443",
    )

    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    if err := cmd.Run(); err != nil {
        fmt.Printf("Erro ao executar o comando: %v\n", err)
        os.Exit(1)
    }

    fmt.Println("CA criada com sucesso.")
}
