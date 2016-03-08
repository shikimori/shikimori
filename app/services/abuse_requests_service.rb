class AbuseRequestsService
  ABUSIVE_USERS = [
    -1
    #5779 # Lumennes
  ]

  SUMMARY_TIMEOUT = 5.minutes

  pattr_initialize :comment, :reporter

  def offtopic faye_token
    if allowed_offtopic_change?
      FayeService
        .new(@reporter, faye_token)
        .offtopic(@comment, !@comment.offtopic?)
    else
      create_abuse_request :offtopic, !@comment.offtopic?, nil
    end
  end

  def summary faye_token
    if allowed_summary_change?
      FayeService
        .new(@reporter, faye_token)
        .summary(@comment, !@comment.summary?)
    else
      create_abuse_request :summary, !@comment.summary?, nil
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
      comment_id: @comment.id,
      user_id: @reporter.id,
      kind: kind,
      value: value,
      state: 'pending',
      reason: reason
    ) unless ABUSIVE_USERS.include?(@reporter.id)
    []
  rescue ActiveRecord::RecordNotUnique
    []
  end

  def allowed_summary_change?
    @reporter.moderator? ||
      (@comment.user_id == @reporter.id &&
      @comment.created_at > SUMMARY_TIMEOUT.ago)
  end

  def allowed_offtopic_change?
    @reporter.moderator? || (
      @comment.can_be_edited_by?(@reporter) &&
      (!@comment.offtopic? || @comment.can_cancel_offtopic?(@reporter))
    )
  end
end
