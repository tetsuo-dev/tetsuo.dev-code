package main

import (
    "os"
    "os/signal"
    "syscall"
    "fmt"
    "github.com/libp2p/go-libp2p"
)

func main() {
    // start a libp2p node that listens on all addresses and a random port each time.
    node, err := libp2p.New(
    libp2p.ListenAddrStrings("/ip4/0.0.0.0/tcp/0"),
    )
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
