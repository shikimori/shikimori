class NotificationsService
  include Singleton

  def nickname_change user, friend, old_nickname, new_nickname
    return if friend.notifications & User::NICKNAME_CHANGE_NOTIFICATIONS == 0

    Message.wo_antispam do
      Message.create!(
        from_id: BotsService.get_poster.id,
        to_id: friend.id,
        kind: MessageType::NicknameChanged,
        body: user.female? ?
          "Ваша подруга [profile=#{user.id}]#{old_nickname}[/profile] изменила никнейм на [profile=#{user.id}]#{new_nickname}[/profile]." :
          "Ваш друг [profile=#{user.id}]#{old_nickname}[/profile] изменил никнейм на [profile=#{user.id}]#{new_nickname}[/profile]."
      )
    end
  end
end
