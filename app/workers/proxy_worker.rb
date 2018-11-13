class ProxyWorker
  include Sidekiq::Worker

  def perform
    ProxyParser.new.import
  end
end
