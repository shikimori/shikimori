class FailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    raise 'fail'
  end
end
