class Topic::Cleanup
  method_object :topic

  COMMENTS_OFFSET = 1_000
  COMMENT_LIVE_TIME = 6.months

  def call
    return if @topic.comments_count < COMMENTS_OFFSET

    comments(@topic).find_each do |comment|
      next if comment.created_at > COMMENT_LIVE_TIME.ago

      Comment::Cleanup.call comment
    end
  end

private

  def comments topic
    topic
      .comments
      .where('id < ?', offset_comment(topic).id)
      .except(:order)
  end

  def offset_comment topic
    topic
      .comments
      .except(:order)
      .order(id: :desc)
      .offset(COMMENTS_OFFSET - 1)
      .limit(1)
      .to_a
      .first
  end
end
