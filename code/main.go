package main

import (
	"encoding/json"
	"os"
	"log"
	"github.com/sanity-io/litter"
	"fmt"
)

func check(e error) {
    if e != nil {
        panic(e)
    }
}

type (
	FullResources struct {
	Orgs     []string               `json:"orgs"`
	Peers    []PeerConfig 								`json:"peers"`
	Orderes  []OrdConfig   						`json:"orderes"`
	Channels []map[string][]string  `json:"channels"`
	}
)

type ChannelsResources struct {
	Channels []map[string][]string  
}

type Orderes struct {
	Orderes []OrdConfig `json:"orderes"`
}

type Peers struct {
	Peers []PeerConfig `json:"peers"`
}

type PeerConfig struct {
    Capacity  string `json:"capacity"`
    Name      string `json:"name"`
    EnrollID  string `json:"enroll-id"`
    EnrollPW  string `json:"enroll-pw"`
    Hosts     string `json:"hosts"`
    IstioPort string `json:"istio-port"`
}

type OrdConfig struct {
		Capacity  string `json:"capacity"`
		Name      string `json:"name"`
		EnrollID  string `json:"enroll-id"`
		EnrollPW  string `json:"enroll-pw"`
		Hosts     string `json:"hosts"`
		IstioPort string `json:"istio-port"`
}

func main() {


	file, err := os.ReadFile("test-b.json")
	if err != nil {
		log.Fatalf("Erro ao ler arquivo: %s", err)
	}

	// var config FullResources
	var peer Peers

	err = json.Unmarshal(file, &peer)
	if err != nil {
		log.Fatalf("Erro ao deserializar JSON: %s", err)
	}

		litter.Dump(peer)

	for i := 0; i < len(peer.Peers); i++ {
		fmt.Println("node Name: " + peer.Peers[i].Name)
		fmt.Println("node Host: " + peer.Peers[i].Hosts)
		fmt.Println("node Capacity: " + peer.Peers[i].Capacity)
	}
}
