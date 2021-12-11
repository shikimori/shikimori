class Comment::Destroy
  method_object :model, :faye

  def call
    topic = @model.topic if topic_comment?

    Changelog::LogDestroy.call @model, @faye.actor
    @faye.destroy @model

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
    @model.commentable.is_a? Topic
  end
end
