# to start faye in console
# RAILS_ENV=development rackup faye.ru -s thin -E production

require 'faye'
require 'faye/redis'
require 'psych'

CONFIG = Psych.load_file(File.expand_path(File.dirname(__FILE__) + '/config/faye.yml'))
Faye::WebSocket.load_adapter 'thin'

# ignore all messages from clients
class ServerAuth
  def incoming message, callback
    if message['channel'] !~ %r{^/meta/}
      if message['data'] && message['data']['token'] == CONFIG[:server_token]
        message['data'].delete 'token'
      else
        message['error'] = 'No client posting is allowed'
      end
    end

    callback.call message
  end
end

class FayeLogger
  def incoming message, callback
    puts "incoming: #{message}" if message['channel'] !~ %r{^/meta/}
    callback.call message
  end

  #def outgoing message, callback
    #puts "outgoing: #{message}" if message['channel'] !~ %r{^/meta/}
    #callback.call message
  #end
end

faye_server = Faye::RackAdapter.new(
  mount: CONFIG[:endpoint],
  timeout: 60,#ENV['RAILS_ENV'] == 'development' ? 1 : 25,
  # disable engine section to fix faye in development mode
  engine: {
    type: Faye::Redis,
    host: 'localhost',
    port: 6379
  }
)

faye_server.on(:handshake) do |client_id|
  puts "handshake of #{client_id}"
end
faye_server.on(:subscribe) do |client_id, channel|
  puts "subscription of #{client_id} for #{channel}"
end
faye_server.on(:publish) do |client_id, channel, data|
  puts "publish of #{client_id} for #{channel} with #{data}"
end

faye_server.add_extension ServerAuth.new
# faye_server.add_extension FayeLogger.new

EM.epoll
EM.set_descriptor_table_size 100000

run faye_server
