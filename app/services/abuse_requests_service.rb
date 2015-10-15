class AbuseRequestsService
  ABUSIVE_USERS = [
    -1
    #5779 # Lumennes
  ]

  pattr_initialize :comment, :reporter

  def offtopic faye_token
    if allowed_offtopic_change?
      FayeService.new(@reporter, faye_token).offtopic(@comment, !@comment.offtopic?)
    else
      make_request :offtopic, !@comment.offtopic?, nil
    end
  end

  def review faye_token
    if allowed_review_change?
      FayeService.new(@reporter, faye_token).review(@comment, !@comment.review?)
    else
      make_request :review, !@comment.review?, nil
    end
  end

  def abuse reason
    make_request :abuse, true, reason
  end

  def spoiler reason
    make_request :spoiler, true, reason
  end

private
  def make_request kind, value, reason
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

  def allowed_review_change?
    @comment.user_id == @reporter.id || @reporter.moderator?
  end

  def allowed_offtopic_change?
   @reporter.moderator? || (
        @comment.can_be_edited_by?(@reporter) &&
        (!@comment.offtopic? || @comment.can_cancel_offtopic?(@reporter))
      )
  end
end
