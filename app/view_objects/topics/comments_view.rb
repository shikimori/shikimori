class Topics::CommentsView < ViewObjectBase
  pattr_initialize :topic, :is_preview

  attr_accessor :summaries_query
  attr_accessor :summary_new_comment

  instance_cache :comments, :new_comment, :folded_comments

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments > 0
  end

  # число свёрнутых комментариев
  def folded_comments
    if summaries_query
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

    (summaries_query ? comments.summaries : comments)
      .decorate
      .to_a
      .reverse
  end

  # адрес прочих комментариев топика
  def fetch_url
    h.fetch_comments_url(
      comment_id: comments.first.id,
      topic_type: topic_type,
      topic_id: topic.id,
      skip: 'SKIP',
      limit: fold_limit,
      review: summaries_query ? 'review' : nil
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
      review: summary_new_comment
    )
  end

private

  def comment_word num
    word = summaries_query ? 'summary' : 'comment'
    i18n_i word, num, :accusative
  end

  # # для адреса подгрузки комментариев
  def topic_type
    Entry.name
  end
end
