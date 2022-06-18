class SimilarUsersWorker
  include Sidekiq::Worker

  sidekiq_options(
    lock: :until_executed,
    lock_args_method: ->(args) { args.first },
    queue: :cpu_intensive,
    retry: false
  )

  def perform user_id, type, threshold, cache_key
    Rails.cache.fetch cache_key, expires_in: 2.weeks do
      fetch User.find(user_id), type.constantize, threshold
    end
  end

private

  def fetch user, klass, threshold
    SimilarUsersService.new(user, klass, threshold).fetch
  end
end
