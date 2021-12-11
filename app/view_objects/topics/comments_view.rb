class Topics::CommentsView < Topics::FoldedCommentsView
  vattr_initialize :topic, :is_preview

  instance_cache :comments, :folded_comments
  delegate :comments_count, to: :topic

  def comments_scope
    @topic
      .comments
      .includes(:user)
  end

  def fetch_url
    h.fetch_comments_url(
      comment_id: comments.first.id,
      topic_type: topic_type,
      topic_id: @topic.id,
      skip: 'SKIP',
      limit: fold_limit
    )
  end

  # pass object linked to topic instead of topic
  # because the latter might not exist yet
  def new_comment
    Comment.new commentable: new_comment_commentable
  end

  def cache_key
    [
      @topic,
      @topic.is_a?(NoTopic) ? @topic.linked : @topic.id,
      @topic.respond_to?(:commented_at) ? @topic.commented_at : nil,
      comments_limit,
      page
    ]
  end

private

  def new_comment_commentable
    @topic.persisted? ? @topic : @topic.linked
  end

  def comment_word number
    i18n_i 'comment', number, :accusative
  end

  # для адреса подгрузки комментариев
  def topic_type
    Topic.name
  end
end
