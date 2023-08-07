package main

import (
    "fmt"
    "os"
    "os/signal"
    "syscall"
    "github.com/libp2p/go-libp2p"
)

func main() {
    // start a libp2p node with default settings
    node, err := libp2p.New()
    if err != nil {
        panic(err)
    }

    // print the node's listening addresses
    fmt.Println("Listen addresses:", node.Addrs())

    // wait for a SIGINT or SIGTERM signal
    ch := make(chan os.Signal, 1)
    signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
    <-ch
    fmt.Println("Received signal, shutting down...")

    // shut the node down
    if err := node.Close(); err != nil {
        panic(err)
    }
}
