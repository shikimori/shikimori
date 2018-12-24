class Achievements::Track
  include Sidekiq::Worker

  sidekiq_options(
    queue: :achievements,
    dead: false
  )

  def perform user_id, user_rate_id, action
    RedisMutex.with_lock("track_achievement_#{user_id}_#{user_rate_id}", block: 0) do
      user = User.find user_id
      neko_update user, user_rate_id, action
    end
  rescue *(Network::FaradayGet::NET_ERRORS + [Neko::RequestError, RedisMutex::LockError])
    self.class.perform_in 1.minute, user_id, user_rate_id, action
  end

private

  def neko_update user, user_rate_id, action
    Neko::Update.call user,
      user_rate_id: user_rate_id,
      action: Types::Neko::Action[action]
  end
end
