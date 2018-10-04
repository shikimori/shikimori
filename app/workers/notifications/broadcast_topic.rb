class Notifications::BroadcastTopic
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args.first },
    queue: :history_jobs
  )

  def perform topic
  end
end
