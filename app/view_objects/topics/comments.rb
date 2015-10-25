class Topics::Comments < ViewObjectBase
  attr_reader :topic, :only_summaries, :is_preview

  instance_cache :comments

  def initialize topic:, only_summaries:, is_preview:
    @topic = topic
    @only_summaries = only_summaries
    @is_preview = is_preview
  end

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments > 0
  end

  # число свёрнутых комментариев
  def folded_comments
    if only_summaries
      topic.comments.summaries.size - comments_limit
    else
      topic.comments_count - comments_limit
    end
  end

  # число отображаемых напрямую комментариев
  def comments_limit
    if is_preview
      h.params[:page] && h.params[:page].to_i > 1 ? 1 : 3
    else
      fold_limit
    end
  end

  # число подгружаемых комментариев из click-loader блока
  def fold_limit
    if is_preview
      10
    else
      20
    end
  end

  # посты топика
  def comments
    comments = topic
      .comments
      .includes(:user)
      .with_viewed(h.current_user)
      .limit(comments_limit)

    (only_summaries ? comments.summaries : comments)
      .decorate
      .to_a
      .reverse
  end

  # адрес прочих комментариев топика
  def fetch_url
    h.fetch_comments_url(
      comment_id: comments.first.id,
      topic_type: Entry.name,
      topic_id: topic.id,
      skip: 'SKIP',
      limit: fold_limit,
      review: only_summaries ? 'review' : nil
    )
  end

  def hide_comments_text
    i18n_t 'hide_comments', comment_word: comment_word(5)

  end

  def show_comments_text
    i18n_t 'show_comments', comment_word: comment_word(5)
  end

  # текст для свёрнутых комментариев
  def load_comments_text
    num = [folded_comments, fold_limit].min

    i18n_t 'load_comments' do |options|
      options[:comment_count] = num
      options[:comment_word] = comment_word(num)

      options[:out_of_total_comments] = if folded_comments > fold_limit
        "#{I18n.t('out_of').downcase} #{folded_comments}"
      end
    end.html_safe
  end

  def new_comment
    Comment.new(
      user: h.current_user,
      commentable: topic,
      review: only_summaries
    )
  end

private

  def comment_word num
    word = only_summaries ? 'summary' : 'comment'
    i18n_i word, num, :accusative
  end
end
