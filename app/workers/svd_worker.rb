class SvdWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    Svd.generate! Svd::Partial
  end
end
