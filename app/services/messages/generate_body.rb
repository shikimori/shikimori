class Messages::GenerateBody < ServiceObjectBase
  include Translation

  pattr_initialize :message
  instance_cache :linked

  def call
    send(message.kind.underscore).html_safe
  end

private

  def linked
    message.linked
  end

  def html_body
    message.html_body
  end
  alias_method :private, :html_body
  alias_method :notification, :html_body
  alias_method :nickname_changed, :html_body

  def action_text
    linked.action_text
  end
  alias_method :ongoing, :action_text
  alias_method :anons, :action_text
  alias_method :episode, :action_text
  alias_method :released, :action_text

  def site_news
    BbCodeFormatter.instance.format_comment linked.body
  end

  def profile_commented
    "Написал#{'а' if message.from.female?} что-то в вашем <a class='b-link' \
href='#{UrlGenerator.instance.profile_url message.to}'>профиле</a>..."
  end

  def friend_request
    response = unless message.read
      " Добавить #{message.from.female? ? 'её' : 'его'} в свой список друзей в ответ?" 
    end

    "Добавил#{'а' if message.from.female?} вас в список друзей.#{response}"
  end

  def quoted_by_user
    "Написал#{'а' if message.from.female?} что-то вам #{linked_name}"
  end

  def subscription_commented
    "Новые сообщения #{linked_name}"
  end

  def warned
    msg = "Вам вынесено предупреждение за"

    if message.linked.comment
      "#{msg} комментарий #{linked_name}."
    else
      "#{msg} удалённый комментарий. Причина: \"#{message.linked.reason}\"."
    end
  end

  def banned
    msg = "Вы забанены на #{message.linked ? message.linked.duration.humanize : '???'}."

    if message.linked && message.linked.comment
      "#{msg} за комментарий #{linked_name}."
    else
      "#{msg}. Причина: \"#{message.linked ? message.linked.reason : '???'}\"."
    end
  end

  def club_request
    BbCodeFormatter.instance.format_comment(
      "Приглашение на вступление в клуб [club]#{message.linked.club_id}[/club]."
    )
  end

  def version_accepted
    BbCodeFormatter.instance.format_comment i18n_t('version_accepted',
      version_id: message.linked.id,
      item_type: message.linked.item_type.underscore,
      item_id: message.linked.item_id
    )
  end

  def version_rejected
    if message.body.present?
      BbCodeFormatter.instance.format_comment i18n_t('version_rejected_with_reason',
        version_id: linked.id,
        item_type: linked.item_type.underscore,
        item_id: linked.item_id,
        moderator: linked.moderator.nickname,
        reason: message.body
      )
    else
      BbCodeFormatter.instance.format_comment i18n_t('version_rejected',
        version_id: linked.id,
        item_type: linked.item_type.underscore,
        item_id: linked.item_id
      )
    end
  end

  def contest_finished
    BbCodeFormatter.instance.format_comment(
      "[contest_status=#{message.linked_id}]"
    )
  end

  def linked_name
    if linked.is_a? Comment
      Messages::MentionSource.call(
        message.linked.commentable,
        message.linked.id
      )

    elsif linked.is_a? Ban
      Messages::MentionSource.call(
        message.linked.comment.commentable,
        message.linked.comment.id
      )

    else
      Messages::MentionSource.call message.linked, nil
    end
  end
end
