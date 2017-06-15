# TODO: move each method to separate class
class Messages::CreateNotification
  include Translation

  pattr_initialize :target

  def user_registered
    locale = @target.locale
    body = i18n_t(
      'user_registered_message',
      faq_url: StickyTopicView.faq(locale).url,
      site_rules_url: StickyTopicView.site_rules(locale).url,
      settings_path: @target.to_param,
      locale: locale
    )

    Message.create_wo_antispam!(
      from_id: User::COSPLAYER_ID,
      to: @target,
      kind: MessageType::Notification,
      body: body
    )
  end

  def moderatable_banned reason
    locale = @target.locale
    body = i18n_t(
      'moderatable_banned.without_reason',
      topic_id: @target.topic(@target.locale).id,
      entry_name: I18n.t(
        "activerecord.models.#{@target.class.name.downcase}",
        locale: @target.locale
      ).downcase,
      locale: locale
    )

    body +=
      if reason.present?
        ' ' + i18n_t(
          'moderatable_banned.reason',
          approver_nickname: @target.approver.nickname,
          reason: reason
        )
      else
        '.'
      end

    Message.create_wo_antispam!(
      from_id: @target.approver_id,
      to_id: @target.user_id,
      kind: MessageType::Notification,
      linked: @target,
      body: body
    )
  end

  def nickname_changed friend, old_nickname, new_nickname
    return if (friend.notifications & User::NICKNAME_CHANGE_NOTIFICATIONS).zero?

    nickname_changed_key = @target.female? ?
      'female_nickname_changed' :
      'male_nickname_changed'

    body = i18n_t(
      nickname_changed_key,
      old_nickname: "[profile=#{@target.id}]#{old_nickname}[/profile]",
      new_nickname: "[profile=#{@target.id}]#{new_nickname}[/profile]",
      locale: friend.locale
    )

    Message.create_wo_antispam!(
      from_id: BotsService.get_poster.id,
      to_id: friend.id,
      kind: MessageType::NicknameChanged,
      body: body
    )
  end

  def round_finished
    @target.contest.topics.each do |topic|
      create_comment(
        @target.contest.user,
        topic,
        "[contest_round_status=#{@target.id}]"
      )
    end
  end

  def contest_finished
    voter_ids = @target
      .rounds
      .joins(matches: :votes)
      .select('distinct(user_id) as voter_id')
      .except(:order)
      .map(&:voter_id)

    create_messages voter_ids,
      kind: MessageType::ContestFinished,
      from: @target.user,
      linked: @target,
      body: nil

    @target.topics.each do |topic|
      create_comment(
        @target.user,
        topic,
        "[contest_status=#{@target.id}]"
      )
    end
  end

private

  def create_comment user, topic, body
    create_params = {
      user: user,
      commentable_id: topic.id,
      commentable_type: 'Topic',
      body: body
    }

    Comment.wo_antispam do
      Comment::Create.call faye(user), create_params, nil
    end
  end

  def faye user
    FayeService.new user, nil
  end

  def create_messages user_ids, kind:, from:, linked:, body:
    messages = user_ids.map do |user_id|
      Message.new(
        from: from,
        to_id: user_id,
        body: body,
        kind: kind,
        linked: linked
      )
    end

    messages.each_slice(1000) { |slice| Message.import slice }
  end
end
