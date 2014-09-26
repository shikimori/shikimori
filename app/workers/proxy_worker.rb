class ProxyWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform is_api
    if is_api
      api_import
    else
      ProxyParser.new.import
    end
  end

private
  def api_import
    proxies = Set.new Proxy.all.map(&:to_s)
    open('http://hideme.ru/api/proxylist.php?out=plain&anon=4&type=h&code=253879821').read.split
      .select {|line| !proxies.include? line }
      .each do |line|
        Proxy.create! ip: line.split(':').first, port: line.split(':').last
      end
  end
end
