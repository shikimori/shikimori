class Achievements::Track
  include Sidekiq::Worker

  sidekiq_options(
    queue: :achievements,
    dead: false
  )

  def perform user_id, user_rate_id, action
    user = User.find user_id

    Neko::Update.call user,
      user_rate_id: user_rate_id,
      action: Types::Neko::Action[action]
  end
end
