import { noise } from '@chainsafe/libp2p-noise'
import { yamux } from '@chainsafe/libp2p-yamux'
import { mdns } from '@libp2p/mdns'
import { mplex } from '@libp2p/mplex'
import { tcp } from '@libp2p/tcp'
import { createLibp2p } from 'libp2p'

const createNode = async () => {
  const node = await createLibp2p({
    addresses: { listen: ['/ip4/0.0.0.0/tcp/0'] },
    transports: [ tcp() ],
    streamMuxers: [ yamux(), mplex() ],
    connectionEncryption: [ noise() ],
    peerDiscovery: [ mdns() ] //default discovery period 10 seconds
  }) //end node

  return node
} //end createNode

;(async () => {
  const [node] = await Promise.all([
    createNode(),
  ])

  console.log('listening on addresses:')
    node.getMultiaddrs().forEach((addr) => {
      console.log(addr.toString())
  })
  console.log('=============================')

  node.addEventListener('peer:discovery', (evt) => console.log('Discovered:', evt.detail.id.toString()))
  //node.addEventListener('peer:discovery', (evt) => console.log('Discovered:', evt.detail))
})()
