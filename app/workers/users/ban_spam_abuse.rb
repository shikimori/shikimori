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
    user.update! read_only_at: BAN_DURATION.from_now
  end

  def notify user
    Message.create_wo_antispam!(
      from: BotsService.get_poster,
      to: user,
      kind: MessageType::Notification,
      body: ban_text(user)
    )
  end

  def ban_text user
    I18n.t(
      'messages/check_spam_abuse.ban_text',
      email: Site::EMAIL,
      locale: locale(user)
    )
  end

  def locale user
    user.russian? ? :ru : :en
  end
end
