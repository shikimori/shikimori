class Messages::GenerateBody < ServiceObjectBase
  include Translation

  pattr_initialize :message
  delegate :linked, :linked_id, to: :message

  def call
    send(@message.kind.underscore).html_safe
  end

private

  def gender
    @gender ||= @message.from.female? ? :female : :male
  end

  def html_body
    @message.html_body
  end
  alias private html_body
  alias notification html_body
  alias nickname_changed html_body

  def anons
    i18n_t 'anons', linked_name: linked.linked.name
  end

  def ongoing
    i18n_t 'ongoing', linked_name: linked.linked.name
  end

  def episode
    i18n_t 'episode', linked_name: linked.linked.name, episode: linked.value
  end

  def released
    i18n_t 'released', linked_name: linked.linked.name
  end

  def site_news
    BbCodes::Text.call linked ? linked.body : @message.body
  end

  def profile_commented
    profile_url = UrlGenerator.instance.profile_url @message.to
    i18n_t '.profile_comment',
      gender: gender,
      profile_url: profile_url
  end

  def friend_request
    unless @message.to.friended? @message.from
      response = i18n_t('friend_request.add', gender: gender)
    end

    "#{i18n_t('friend_request.added', gender: gender)} #{response}".strip
  end

  def quoted_by_user
    i18n_t 'quoted_by_user',
      gender: gender,
      linked_name: linked_name,
      comment_url: UrlGenerator.instance.comment_url(linked)
  end

  def subscription_commented
    i18n_t 'subscription_commented', linked_name: linked_name
  end

  def warned
    banned is_warn: true
  end

  def banned is_warn: false # rubocop:disable PerceivedComplexity, CyclomaticComplexity, AbcSize
    key =
      if linked&.target_type
        linked.target ? :target : :missing
      else
        :other
      end

    i18n_t "#{is_warn ? :warned : :banned}.#{key}",
      gender: gender,
      duration: linked&.duration&.humanize || '???',
      linked_name: (ban_linked_name if linked&.target),
      target_type_name: (
        linked.target_type.constantize.model_name.human.downcase if linked&.target_type
      ),
      reason: linked&.reason ? BbCodes::Text.call(linked.reason) : '???'
  end

  def club_request
    BbCodes::Text.call(
      i18n_t('club_request', club_id: linked&.club_id)
    )
  end

  def version_accepted
    BbCodes::Text.call(
      i18n_t(
        'version_accepted',
        version_id: linked.id,
        item_type: linked.item_type.underscore,
        item_id: linked.item_id
      )
    )
  end

  def version_rejected # rubocop:disable AbcSize, MethodLength
    if @message.body.present?
      BbCodes::Text.call i18n_t(
        'version_rejected_with_reason',
        version_id: linked.id,
        item_type: linked.item_type.underscore,
        item_id: linked.item_id,
        moderator: linked.moderator.nickname,
        reason: @message.body
      )
    else
      BbCodes::Text.call i18n_t(
        'version_rejected',
        version_id: linked.id,
        item_type: linked.item_type.underscore,
        item_id: linked.item_id
      )
    end
  end

  def contest_started
    BbCodes::Text.call(
      "[contest_status=#{linked_id} started]"
    )
  end

  def contest_finished
    BbCodes::Text.call(
      "[contest_status=#{linked_id} finished]"
    )
  end

  def club_broadcast
    BbCodes::Text.call linked.body
  end

  def ban_linked_name
    if linked.target.is_a?(Review) || linked.target.is_a?(Topic)
      Messages::MentionSource.call(linked.target, is_simple: true)
    else
      linked_name
    end
  end

  def linked_name
    case linked
      when Comment
        Messages::MentionSource.call(
          linked.commentable,
          comment_id: linked.id
        )

      when Ban
        Messages::MentionSource.call(
          linked.comment.commentable,
          comment_id: linked.comment.id
        ).gsub(/\.\Z/, '')

      else
        Messages::MentionSource.call linked
    end
  end
end
