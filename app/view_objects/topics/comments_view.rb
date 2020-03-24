class Topics::CommentsView < ViewObjectBase
  vattr_initialize :topic, :is_preview

  instance_cache :comments, :folded_comments
  instance_cache :only_summaries_shown?
  instance_cache :topic_comments_policy

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments.positive?
  end

  # число свёрнутых комментариев
  def folded_comments
    return 0 if topic_comments_policy.comments_count.zero?

    if only_summaries_shown?
      topic_comments_policy.summaries_count - comments_limit
    else
      topic_comments_policy.comments_count - comments_limit
    end
  end

  # число отображаемых напрямую комментариев
  def comments_limit
    if @is_preview
      page > 1 ? 1 : 3
    else
      fold_limit
    end
  end

  # число подгружаемых комментариев из comments-loader блока
  def fold_limit
    if @is_preview
      10
    else
      20
    end
  end

  # посты топика
  def comments
    comments = @topic
      .comments
      .includes(:user)
      .limit(comments_limit)

    (only_summaries_shown? ? comments.summaries : comments)
      .decorate
      .to_a
      .reverse
  end

  # адрес прочих комментариев топика
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

  def hide_comments_text
    i18n_t 'hide_comments',
      comment_word: comment_word(folded_comments),
      comment_count: folded_comments
  end

  def show_comments_text
    i18n_t 'show_comments',
      comment_word: comment_word(folded_comments),
      comment_count: folded_comments
  end

  # текст для свёрнутых комментариев
  def load_comments_text
    num = [folded_comments, fold_limit].min

    i18n_t 'load_comments' do |options|
      options[:comment_count] = num
      options[:comment_word] = comment_word(num)
      options[:of_total_comments] =
        if folded_comments > fold_limit
          "#{I18n.t('of').downcase} #{folded_comments}"
        end
    end.html_safe
  end

  # pass object linked to topic instead of topic
  # because the latter might not exist yet
  def new_comment
    Comment.new(
      commentable: new_comment_commentable,
      is_summary: new_comment_summary?
    )
  end

  def cached_comments?
    false
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
