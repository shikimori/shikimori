class AbuseRequestsService
  CHANGE_ALLOWED_TIMEOUT = 5.minutes

  pattr_initialize %i[comment topic review reporter!]

  def offtopic faye_token
    raise CanCan::AccessDenied unless forum_entry.is_a? Comment

    value_to_change = !forum_entry.offtopic?

    if allowed_direct_change?
      faye_service(faye_token).offtopic forum_entry, value_to_change
    else
      abuse_request = create_abuse_request :offtopic, value_to_change, nil

      if can_manage? abuse_request
        abuse_request.take! @reporter, faye_token
        forum_entry.reload
        abuse_request.affected_ids
      else
        []
      end
    end
  end

  def convert_review _faye_token
    raise CanCan::AccessDenied unless forum_entry.is_a?(Comment) || forum_entry.is_a?(Review)

    faye_token = nil # token is purposely nullified so current user could receive faye event

    if allowed_direct_change?
      faye_service(faye_token).convert_review forum_entry
    else
      abuse_request = create_abuse_request :convert_review, nil, nil

      if can_manage? abuse_request
        abuse_request&.take! @reporter, faye_token
      end
    end
  end

  def abuse reason
    create_abuse_request :abuse, true, reason
  end

  def spoiler reason
    create_abuse_request :spoiler, true, reason
  end

private

  def create_abuse_request kind, value, reason
    AbuseRequest.create!(
      comment_id: @comment&.id,
      review_id: @review&.id,
      topic_id: @topic&.id,
      user_id: @reporter.id,
      kind: kind,
      value: value,
      state: 'pending',
      reason: reason
    )
  rescue ActiveRecord::RecordNotUnique
    find_abuse_request kind, value
  end

  def find_abuse_request kind, value
    AbuseRequest.find_by(
      comment_id: @comment&.id,
      review_id: @review&.id,
      topic_id: @topic&.id,
      kind: kind,
      value: value,
      state: 'pending'
    )
  end

  def forum_entry
    @comment || @topic || @review
  end

  def allowed_direct_change?
    own_forum_entry? && forum_entry.created_at > CHANGE_ALLOWED_TIMEOUT.ago
  end

  def own_forum_entry?
    forum_entry.user_id == @reporter.id
  end

  def can_manage? abuse_request
    abuse_request && Ability.new(@reporter).can?(:manage, abuse_request)
  end

  def faye_service faye_token
    FayeService.new @reporter, faye_token
  end
end
