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
      make_request :offtopic, !@comment.offtopic?
    end
  end

  def review faye_token
    if allowed_review_change?
      FayeService.new(@reporter, faye_token).review(@comment, !@comment.review?)
    else
      make_request :review, !@comment.review?
    end
  end

  def abuse
    make_request :abuse, true
  end

  def spoiler
    make_request :spoiler, true
  end

private
  def make_request kind, value
    AbuseRequest.create!(
      comment_id: @comment.id,
      user_id: @reporter.id,
      kind: kind,
      value: value,
      state: 'pending'
    ) unless ABUSIVE_USERS.include?(@reporter.id)
    []
  rescue ActiveRecord::RecordNotUnique
    []
  end

  def allowed_review_change?
    @comment.user_id == @reporter.id || @reporter.abuse_requests_moderator?
  end

  def allowed_offtopic_change?
   @reporter.abuse_requests_moderator? || (
        @comment.can_be_edited_by?(@reporter) &&
        (!@comment.offtopic? || @comment.can_cancel_offtopic?(@reporter))
      )
  end
end
