const Libp2p = require('libp2p')
const TCP = require('libp2p-tcp')
const { NOISE } = require('libp2p-noise')
const MPLEX = require('libp2p-mplex')
const process = require('process')
const { multiaddr } = require('multiaddr')
const Gossipsub = require('libp2p-gossipsub')
const Bootstrap = require('libp2p-bootstrap')
const bootstrapers = require('./bootstrapers')
const MulticastDNS = require('libp2p-mdns')
const { fromString: uint8ArrayFromString } = require('uint8arrays/from-string')
const { toString: uint8ArrayToString } = require('uint8arrays/to-string')
const express = require('express')
const bodyParser = require('body-parser')
const request = require('request')

;(async () => {
  const node = await Libp2p.create({
    addresses: {
      listen: ['/ip4/0.0.0.0/tcp/0']
    },
    modules: {
      transport: [TCP],
      streamMuxer: [MPLEX],
      connEncryption: [NOISE],
      peerDiscovery: [MulticastDNS],
      pubsub: Gossipsub
    },
    config: {
      peerDiscovery: {
        mdns: {
          interval: 60e3,
          enabled: true
        }
      },
      pubsub: {
        enabled: true,
        emitSelf: false
      }
    }
  })

  node.connectionManager.on('peer:connect', (connection) => {
    console.log('Connection established to:', connection.remotePeer.toB58String())	// Emitted when a peer has been found
  })

  node.on('peer:discovery', (peerId) => {
    // No need to dial, autoDial is on
    console.log('Discovered:', peerId.toB58String())
  })

  console.log('My Node ID: ', node.peerId.toB58String())
//  console.log(node)

  await node.start()

  // now the node has started we can do our pubsub stuff

  const topic = 'news'
  node.pubsub.subscribe(topic)
  console.log('pubsub subscribe')

  node.pubsub.on(topic, (msg) => {
    console.log(`received: ${uint8ArrayToString(msg.data)} from ${msg.from}`)
    console.log(`pulling config from ${msg.from}`)
    let conf_url = 'http://' + msg.data + ':8888/config'
    request(conf_url, { json: true }, (err, res, body) => {
      if (err) { return console.log(err); }
      console.log('Body that I got is: ', body)
      const unit_config = body
      console.log('------')
      console.log(unit_config)
      // let's try to put the config locally
      request.put({
        headers: {'content-type' : 'application/json'},
        url: 'http://127.0.0.1:8888/config',
        json: unit_config
      }, function (error, response, bdy){
           console.log(bdy)
      }) //end request.put
    })  
  })

  
  app = express()
  port = process.env.PORT || 3000;
  
  app.use(bodyParser.json())

  app.post('/config', (req, res) => {
    var today = new Date();
    var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time;
    let ar_host_port = req.rawHeaders[1].split(":")
    console.log('publishing: ' + dateTime + ' ' + ar_host_port[0])
    res.end('Published config event to all other nodes');
    node.pubsub.publish(topic, ar_host_port[0])
  })
  app.listen(port, () => {
    console.log('app listeneing on: ' + port)
  })

})();
