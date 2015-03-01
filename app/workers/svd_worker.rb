class SvdWorker
  include Sidekiq::Worker
  sidekiq_options unique: true, dead: false
  sidekiq_retry_in { 60 * 60 * 24 }

  def perform
    Svd.generate! Svd::Partial
  end
end
