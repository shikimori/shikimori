class NotificationsService
  include Translation

  pattr_initialize :target

  def nickname_changed friend, old_nickname, new_nickname
    return if friend.notifications & User::NICKNAME_CHANGE_NOTIFICATIONS == 0

    nickname_changed_key = target.female? ?
      'female_nickname_changed' :
      'male_nickname_changed'

    Message.create_wo_antispam!(
      from_id: BotsService.get_poster.id,
      to_id: friend.id,
      kind: MessageType::NicknameChanged,
      body: i18n_t(
        nickname_changed_key,
        old_nickname: "[profile=#{target.id}]#{old_nickname}[/profile]",
        new_nickname: "[profile=#{target.id}]#{new_nickname}[/profile]",
        locale: I18n::LOCALES[friend.language]
      )
    )
  end

  def round_finished
    comment = Comment.new(
      user: target.contest.user,
      commentable: target.contest.thread,
      body: "[contest_round=#{target.id}]"
    )

    Comment.wo_antispam do
      FayeService.new(target.contest.user, nil).create comment
    end
  end
end
