const http = require('http')
const faye = require('faye')

const { join, resolve } = require('path')
const { safeLoad } = require('js-yaml')
const { readFileSync } = require('fs')

const configPath = resolve('config')
const config = safeLoad(readFileSync(join(configPath, 'faye.yml'), 'utf8'))

const server = http.createServer()
const bayeux = new faye.NodeAdapter({mount: config[':endpoint']})

var serverAuth = {
  incoming: function(message, callback) {
    // Let non-subscribe messages through
    if (message.channel.match(/^\/meta\//)) {
      return callback(message)
    }

    // Check the token
    if (message['data'] && message['data']['token'] == config[':server_token']) {
      delete message['data']['token']
    } else {
      message['error'] = 'No client posting is allowed'
    }

    // Call the server back now we're done
    callback(message);
  }
}
var fayeLogger = {
  incoming: function(message, callback) {
    if (!message.channel.match(/^\/meta\//)) {
      console.log(`-> ${JSON.stringify(message)}`)
    }

    // Call the server back now we're done
    callback(message);
  },
  outgoing: function(message, callback) {
    if (!message.channel.match(/^\/meta\//)) {
      console.log(`<- ${JSON.stringify(message)}`)
    }

    // Call the server back now we're done
    callback(message);
  }
}

bayeux.on('handshake', function(client_id) {
  console.log(`!! handshake of ${client_id}`)
})
bayeux.on('subscribe', function(client_id, channel) {
  console.log(`!! subscription of ${client_id} for ${channel}`)
})
bayeux.on('publish', function(client_id, channel, data) {
  console.log(`!! publish of ${client_id} for ${channel} with ${data}`)
})

bayeux.addExtension(serverAuth)
bayeux.addExtension(fayeLogger)
bayeux.attach(server)

server.listen(9292)
