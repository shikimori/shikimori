class Users::BanSpamAbuse
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  BAN_DURATION = 100.years

  def perform user_id
    user = User.find user_id

    ban user
    notify user
  end

private

  def ban user
    user.read_only_at = BAN_DURATION.from_now
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
      'messages/check_spam_abuse.ban_text',
      gender: user.sex,
      email: Shikimori::EMAIL,
      locale: user.locale.to_sym
    )
  end
end
