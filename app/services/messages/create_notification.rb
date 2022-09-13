class Messages::CreateNotification # rubocop:disable ClassLength
  include Translation

  pattr_initialize :target

  def user_registered
    body = i18n_t(
      'user_registered_message',
      faq_url: StickyClubView.faq.object.url,
      site_rules_url: StickyTopicView.site_rules.object.url,
      settings_path: @target.to_param,
      locale: @target.locale
    )

    Message.create_wo_antispam!(
      from_id: User::MESSANGER_ID,
      to: @target,
      kind: MessageType::NOTIFICATION,
      body: body
    )
  end

  def moderatable_banned reason # rubocop:disable MethodLength, AbcSize
    body = i18n_t(
      'moderatable_banned.without_reason',
      topic_id: @target.topic.id,
      entry_name: I18n.t(
        "activerecord.models.#{@target.class.name.downcase}"
      ).downcase
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
      kind: MessageType::NOTIFICATION,
      linked: @target,
      body: body
    )
  end

  def nickname_changed friend, old_nickname, new_nickname
    return unless friend.notification_settings_friend_nickname_change?

    body = i18n_t(
      'nickname_changed',
      gender: friend.sex,
      old_nickname: "[profile=#{@target.id}]#{old_nickname}[/profile]",
      new_nickname: "[profile=#{@target.id}]#{new_nickname}[/profile]",
      locale: friend.locale.to_sym
    )

    Message.create_wo_antispam!(
      from_id: BotsService.get_poster.id,
      to_id: friend.id,
      kind: MessageType::NICKNAME_CHANGED,
      body: body
    )
  end

  def round_finished
    create_comment(
      @target.contest.user,
      @target.contest.topic,
      "[contest_round_status=#{@target.id} finished]"
    )
  end

  def contest_started
    create_comment(
      @target.user,
      @target.topic,
      "[contest_status=#{@target.id} started]"
    )

    Topics::Generate::News::ContestStatusTopic.call(
      model: @target,
      user: @target.user,
      action: Types::Topic::ContestStatusTopic::Action[:started]
    )
  end

  def contest_finished
    create_comment(
      @target.user,
      @target.topic,
      "[contest_status=#{@target.id} finished]"
    )

    Topics::Generate::News::ContestStatusTopic.call(
      model: @target,
      user: @target.user,
      action: Types::Topic::ContestStatusTopic::Action[:finished],
    )
  end

  def bad_email
    body = i18n_t(
      'bad_email_message',
      gender: @target.sex,
      email: @target.email,
      locale: @target.locale.to_sym
    )

    Message.create_wo_antispam!(
      from_id: BotsService.get_poster.id,
      to_id: @target.id,
      kind: MessageType::NOTIFICATION,
      body: body
    )
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
      Comment::Create.call(
        faye: faye(user),
        params: create_params
      )
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
