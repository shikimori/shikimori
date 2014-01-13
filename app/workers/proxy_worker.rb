class ProxyWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    ProxyParser.new.import
  end
end
