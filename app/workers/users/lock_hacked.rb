class Users::LockHacked
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform user_id
    user = User.find user_id

    lock user
    notify user
  end

private

  def lock user
    user.password = Devise.friendly_token
    user.save! validate: false
  end

  def notify user
    Message.create_wo_antispam!(
      from_id: User::BANHAMMER_ID,
      to: user,
      kind: MessageType::PRIVATE,
      body: ban_text(user)
    )
  end

  def ban_text user
    I18n.t(
      'users/check_hacked.lock_text',
      email: Shikimori::EMAIL,
      locale: user.locale.to_sym,
      recovery_url: UrlGenerator.instance.new_user_password_url(
        protocol: Shikimori::PROTOCOL
      )
    )
  end
end
