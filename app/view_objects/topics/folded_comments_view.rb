class Topics::FoldedCommentsView < ViewObjectBase
  attr_implement :comments_scope,
    :comments_count,
    :fetch_url

  def comments
    comments_scope
      .includes(:topic)
      .limit(comments_limit)
      .decorate
      .to_a
      .reverse
  end

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments.positive?
  end

  # число свёрнутых комментариев
  def folded_comments
    return 0 if comments_count.zero?

    comments_count - comments_limit
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

  def comment_word number
    i18n_i 'comment', number, :accusative
  end
end
