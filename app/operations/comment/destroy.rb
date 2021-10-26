class Comment::Destroy
  method_object :comment, :faye

  def call
    topic = @comment.topic if topic_comment?

    @faye.destroy @comment

    touch_topic topic.reload if topic
  end

private

  def touch_topic topic
    updated_at = topic.comments_count.positive? ?
      topic.comments.first.created_at :
      topic.created_at

    topic.update_column :updated_at, updated_at
  end

  def topic_comment?
    @comment.commentable.is_a? Topic
  end
end
