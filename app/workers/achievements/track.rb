class Achievements::Track
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executing,
    queue: :achievements,
    dead: false
  )
  sidekiq_retry_in { 60 * 60 * 24 }

  RETRYABLE_OPTIONS = {
    tries: 5,
    on: Network::FaradayGet::NET_ERRORS,
    sleep: 3
  }

  def perform user_id, user_rate_id, action
    user = User.find user_id

    Retryable.retryable RETRYABLE_OPTIONS do
      neko_update user, user_rate_id, action
    end
  end

private

  def neko_update user, user_rate_id, action
    Neko::Update.call user,
      user_rate_id: user_rate_id,
      action: Types::Neko::Action[action]
  end
end
