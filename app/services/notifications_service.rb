class NotificationsService
  include Singleton
  include Translation

  def nickname_change user, friend, old_nickname, new_nickname
    return if friend.notifications & User::NICKNAME_CHANGE_NOTIFICATIONS == 0

    nickname_changed_key = user.female? ?
      'female_nickname_changed' :
      'male_nickname_changed'

    Message.create_wo_antispam!(
      from_id: BotsService.get_poster.id,
      to_id: friend.id,
      kind: MessageType::NicknameChanged,
      body: i18n_t(
        nickname_changed_key,
        old_nickname: "[profile=#{user.id}]#{old_nickname}[/profile]",
        new_nickname: "[profile=#{user.id}]#{new_nickname}[/profile]"
      )
    )
  end
end
