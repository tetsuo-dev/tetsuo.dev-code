package main

import (
    "context"
    "bufio"
    "fmt"
    "os"
    "os/signal"
    "syscall"

    "github.com/libp2p/go-libp2p"
    peerstore "github.com/libp2p/go-libp2p/core/peer"
    "github.com/libp2p/go-libp2p/p2p/protocol/ping"
    multiaddr "github.com/multiformats/go-multiaddr"
    "github.com/libp2p/go-libp2p/core/network"
    _"github.com/libp2p/go-libp2p/p2p/discovery/mdns"
)

type config struct {
	RendezvousString string
	ProtocolID       string
	listenHost       string
	listenPort       int
}

func handleStream(stream network.Stream) {
	fmt.Println("Got a new stream!")

	// Create a buffer stream for non-blocking read and write.
	rw := bufio.NewReadWriter(bufio.NewReader(stream), bufio.NewWriter(stream))

	go readData(rw)
	go writeData(rw)

	// 'stream' will stay open until you close it (or the other side closes it).
}


func readData(rw *bufio.ReadWriter) {
	for {
		str, err := rw.ReadString('\n')
		if err != nil {
			fmt.Println("Error reading from buffer")
			panic(err)
		}

		if str == "" {
			return
		}
		if str != "\n" {
			// Green console colour: 	\x1b[32m
			// Reset console colour: 	\x1b[0m
			fmt.Printf("\x1b[32m%s\x1b[0m> ", str)
		}

	}
}

func writeData(rw *bufio.ReadWriter) {
	stdReader := bufio.NewReader(os.Stdin)

	for {
		fmt.Print("> ")
		sendData, err := stdReader.ReadString('\n')
		if err != nil {
			fmt.Println("Error reading from stdin")
			panic(err)
		}

		_, err = rw.WriteString(fmt.Sprintf("%s\n", sendData))
		if err != nil {
			fmt.Println("Error writing to buffer")
			panic(err)
		}
		err = rw.Flush()
		if err != nil {
			fmt.Println("Error flushing buffer")
			panic(err)
		}
	}
}

func main() {

    //var c = config{"rendesvous", "0.0.0.0", "/chat/1.1.0", 4001}


    // start a libp2p node that listens on a random local TCP port,
    // but without running the built-in ping protocol
    node, err := libp2p.New(
        libp2p.ListenAddrStrings("/ip4/0.0.0.0/tcp/0"),
        libp2p.Ping(false),
    )
    if err != nil {
        panic(err)
    }

    // configure our own ping protocol
    pingService := &ping.PingService{Host: node}
    node.SetStreamHandler(ping.ID, pingService.PingHandler)

    // print the node's PeerInfo in multiaddr format
    peerInfo := peerstore.AddrInfo{
        ID:    node.ID(),
        Addrs: node.Addrs(),
    }
    addrs, err := peerstore.AddrInfoToP2pAddrs(&peerInfo)
    if err != nil {
        panic(err)
    }
    fmt.Println("libp2p node address:", addrs[0])

    // if a remote peer has been passed on the command line, connect to it
    // and send it 5 ping messages, otherwise wait for a signal to stop
    if len(os.Args) > 1 {
        addr, err := multiaddr.NewMultiaddr(os.Args[1])
        if err != nil {
            panic(err)
        }
        peer, err := peerstore.AddrInfoFromP2pAddr(addr)
        if err != nil {
            panic(err)
        }
        if err := node.Connect(context.Background(), *peer); err != nil {
            panic(err)
        }
        fmt.Println("sending 5 ping messages to", addr)
        ch := pingService.Ping(context.Background(), peer.ID)
        for i := 0; i < 5; i++ {
            res := <-ch
            fmt.Println("pinged", addr, "in", res.RTT)
        }
    } else {
        // wait for a SIGINT or SIGTERM signal
        ch := make(chan os.Signal, 1)
        signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
        <-ch
        fmt.Println("Received signal, shutting down...")
    }

    // shut the node down
    if err := node.Close(); err != nil {
        panic(err)
    }
}
