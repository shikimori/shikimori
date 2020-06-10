class Topics::CommentsView < Topics::FoldedCommentsView
  vattr_initialize :topic, :is_preview

  instance_cache :comments,
    :folded_comments,
    :only_summaries_shown?,
    :topic_comments_policy

  def comments_scope
    comments = @topic
      .comments
      .includes(:user)

    if only_summaries_shown?
      comments.summaries
    else
      comments
    end
  end

  def fetch_url
    h.fetch_comments_url(
      comment_id: comments.first.id,
      topic_type: topic_type,
      topic_id: @topic.id,
      skip: 'SKIP',
      limit: fold_limit,
      is_summary: only_summaries_shown? ? 'is_summary' : nil
    )
  end

  # pass object linked to topic instead of topic
  # because the latter might not exist yet
  def new_comment
    Comment.new(
      commentable: new_comment_commentable,
      is_summary: new_comment_summary?
    )
  end

  def cache_key
    [
      @topic.is_a?(NoTopic) ? @topic.linked : @topic.id,
      @topic.respond_to?(:commented_at) ?
        @topic.commented_at : @topic.updated_at,
      comments_limit,
      page,
      only_summaries_shown?,
      new_comment_summary?
    ]
  end

  def comments_count
    only_summaries_shown? ?
      topic_comments_policy.summaries_count :
      topic_comments_policy.comments_count
  end

private

  def new_comment_commentable
    @topic.persisted? ? @topic : @topic.linked
  end

  def only_summaries_shown?
    return false unless %w[animes mangas ranobe].include? h.params[:controller]
    return true if h.params[:action] == 'summaries'

    h.params[:action] == 'show' &&
      topic_comments_policy.summaries_count.positive?
  end

  def new_comment_summary?
    %w[animes mangas ranobe].include?(h.params[:controller]) &&
      h.params[:action] == 'summaries'
  end

  def comment_word number
    word = only_summaries_shown? ? 'summary' : 'comment'
    i18n_i word, number, :accusative
  end

  # для адреса подгрузки комментариев
  def topic_type
    Topic.name
  end

  def topic_comments_policy
    Topic::CommentsPolicy.new @topic
  end
end
