class NotificationsService
  include Translation

  pattr_initialize :target

  def user_registered
    Message.create_wo_antispam!(
      from_id: User::Cosplayer_ID,
      to: target,
      kind: MessageType::Notification,
      body: "Добро пожаловать.
[url=http://#{Site::DOMAIN}/s/85018-FAQ-Chasto-zadavaemye-voprosy]Здесь[/url] находятся ответы на наиболее часто задаваемые вопросы.
Импортировать список аниме и манги из [url=http://myanimelist.net]myanimelist.net[/url] или [url=http://anime-planet.com]anime-planet.com[/url] можно в [url=/#{target.to_param}/edit]настройках профиля[/url]. Там же можно изменить свой никнейм.
Перед постингом на форуме рекомендуем ознакомиться с [url=http://#{Site::DOMAIN}/s/79042-Pravila-sayta]правилами сайта[/url].

Если возникнут вопросы или пожелания - пишите на форуме, мы постараемся вам ответить."
    )
  end

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
    create_comment Comment.new(
      user: target.contest.user,
      commentable: target.contest.thread,
      body: "[contest_round_status=#{target.id}]"
    )
  end

  def contest_finished
    voter_ids = target
      .rounds
      .joins(matches: :votes)
      .select('distinct(user_id) as voter_id')
      .except(:order)
      .map(&:voter_id)

    create_messages voter_ids,
      kind: MessageType::ContestFinished,
      from: target.user,
      linked: target,
      body: nil

    create_comment Comment.new(
      user: target.user,
      commentable: target.thread,
      body: "[contest_status=#{target.id}]"
    )
  end

private

  def create_comment comment
    Comment.wo_antispam do
      FayeService.new(comment.user, nil).create comment
    end
  end

  def create_messages user_ids, kind:, from:, linked:, body:
    messages = user_ids.map do |user_id|
      Message.new(
        from: from,
        to_id: user_id,
        body: body,
        kind: kind,
        linked: linked,
      )
    end

    messages.each_slice(1000) { |slice| Message.import slice }
  end
end
