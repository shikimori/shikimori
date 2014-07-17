# запуск faye из консоли
# RAILS_ENV=development rackup faye.ru -s thin -E production

require 'faye'
require 'faye/redis'
require 'psych'

CONFIG = Psych.load_file(File.expand_path(File.dirname(__FILE__) + '/config/faye.yml'))
Faye::WebSocket.load_adapter 'thin'

# все сообщения от клиентов будем отвергать
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
  engine: {
    type: Faye::Redis,
    host: 'localhost',
    port: 6379
  }
)

faye_server.add_extension ServerAuth.new
faye_server.add_extension FayeLogger.new

EM.epoll
EM.set_descriptor_table_size 100000

run faye_server
