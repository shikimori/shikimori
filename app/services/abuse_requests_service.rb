class AbuseRequestsService
  def initialize comment, reporter
    @comment = comment
    @reporter = reporter
  end

  def offtopic
    if @reporter.abuse_requests_moderator? || (
        @comment.can_be_edited_by?(@reporter) && (!@comment.offtopic? || @comment.can_cancel_offtopic?(@reporter))
      )
      @comment.mark 'offtopic', !@comment.offtopic?
    else
      make_request :offtopic, !@comment.offtopic?
    end
  end

  def review
    if @comment.user_id == @reporter.id || @reporter.abuse_requests_moderator?
      @comment.mark 'review', !@comment.review?
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
    AbuseRequest.create! comment_id: @comment.id, user_id: @reporter.id, kind: kind, value: value
    []
  rescue ActiveRecord::RecordNotUnique
    []
  end
end
