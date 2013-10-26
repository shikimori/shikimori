# encoding: utf-8

require 'faye'
require 'faye/redis'
#require 'rack/cors'

#use Rack::Cors do
  #allow do
    #origins '*'
    #resource '/faye', :headers => :any, :methods => [:get, :post, :options]
  #end
#end

Faye::WebSocket.load_adapter('thin')

# все сообщения от клиентов будем отвергать
class ServerAuth
  def incoming(message, callback)
    message['error'] = 'No client posting is allowed' if message['channel'] !~ %r{^/meta/}

    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new({
  :mount => '/faye-server',
  :timeout => 25,
  :engine  => {
    :type  => Faye::Redis,
    :host  => 'localhost',
    :port  => 6379
  }
})

faye_server.add_extension(ServerAuth.new)
run faye_server
