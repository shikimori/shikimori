class ProxyWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform
    ProxyParser.new.import
  end
end
