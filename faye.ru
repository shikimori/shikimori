require 'faye'
require 'faye/redis'

Faye::WebSocket.load_adapter('thin')

# все сообщения от клиентов будем отвергать
class ServerAuth
  def incoming(message, callback)
    message['error'] = 'No client posting is allowed' if message['channel'] !~ %r{^/meta/}

    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new({
  mount: '/faye-server',
  timeout: ENV['RAILS_ENV'] == 'development' ? 1 : 25,
  engine: {
    type: Faye::Redis,
    host: 'localhost',
    port: 6379
  }
})

faye_server.add_extension(ServerAuth.new)
run faye_server
