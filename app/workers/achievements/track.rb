class Achievements::Track
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executing,
    queue: :achievements,
    dead: false
  )
  sidekiq_retry_in { 60 * 60 * 24 }

  MUTEX_OPTIONS = { block: 60, expire: 60 }
  ERRORS = Network::FaradayGet::NET_ERRORS + [RedisMutex::LockError]

  def perform user_id, user_rate_id, action
    # user = User.find user_id

    # Retryable.retryable tries: 5, on: ERRORS, sleep: 3 do
      # RedisMutex.with_lock("neko_#{user_id}", MUTEX_OPTIONS) do
        # neko_update user, user_rate_id, action
      # end
    # end
  end

private

  def neko_update user, user_rate_id, action
    Neko::Update.call user,
      user_rate_id: user_rate_id,
      action: Types::Neko::Action[action]
  end
end
