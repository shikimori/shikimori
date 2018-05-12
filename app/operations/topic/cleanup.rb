class Topic::Cleanup
  method_object :topic

  COMMENTS_OFFSET = 1_000

  def call
    return if @topic.comments_count < COMMENTS_OFFSET

    comments(@topic).find_each { |comment| Comment::Cleanup.call comment }
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
      .order(id: :desc)
      .offset(COMMENTS_OFFSET - 1)
      .limit(1)
      .to_a
      .first
  end
end
