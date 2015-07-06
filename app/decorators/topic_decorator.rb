class TopicDecorator < BaseDecorator
  include Translation
  instance_cache :comments

  # имя топика
  def display_title
    if !preview?
      user.nickname
    elsif generated_news? || object.class == AniMangaComment
      h.localized_name object.linked
    elsif contest? || object.respond_to?(:title)
      object.title
    else
      object.name
    end
  end

  def body
    if review?
      linked.text
    else
      object.body
    end
  end

  # текст топика
  def html_body
    Rails.cache.fetch [object, linked, h.russian_names_key, 'body'], expires_in: 2.weeks do
      if review?
        BbCodeFormatter.instance.format_description linked.text, linked
      else
        BbCodeFormatter.instance.format_comment object.body
      end
    end
  end

  # картинка топика(аватарка автора)
  def avatar
    if special? && linked.respond_to?(:image) && !(news? && !generated? && !preview?)
      ImageUrlGenerator.instance.url linked, :x48
    elsif special? && linked.respond_to?(:logo)
      ImageUrlGenerator.instance.url linked, :x48
    elsif review?
      ImageUrlGenerator.instance.url linked.target, :x48
    else
      user.avatar_url(48)
    end
  end

  def avatar2x
    if special? && linked.respond_to?(:image) && !(news? && !generated? && !preview?)
      ImageUrlGenerator.instance.url linked, :x96
    elsif special? && linked.respond_to?(:logo)
      ImageUrlGenerator.instance.url linked, :x96
    elsif review?
      ImageUrlGenerator.instance.url linked.target, :x96
    else
      user.avatar_url(80)
    end
  end

  # дата создания топика
  def date
    I18n.l(created_at, format: '%e %B %Y').strip
  end

  # надо ли свёртывать длинный контент топика?
  def should_shorten?
    !news? || (news? && generated?) || (news? && object.body !~ /\[wall\]/)
  end

  # показывать ли тело топика?
  def show_body?
    preview? || !generated? || contest? || review?
  end

  # показывать ли автора в header блоке
  def show_author_in_header?
    !generated_news?
  end

  # показывать ли автора в footer блоке
  def show_author_in_footer?
    preview? && (news? || review?) && (!show_author_in_header? || avatar != user.avatar_url(48))
  end

  # по опросу ли данный топик
  def contest?
    object.class == ContestComment
  end

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments > 0
  end

  # число свёрнутых комментариев
  def folded_comments
    if reviews_only?
      object.comments.reviews.size - comments_limit
    else
      object.comments_count - comments_limit
    end
  end

  # число отображаемых напрямую комментариев
  def comments_limit
    if preview?
      h.params[:page] && h.params[:page].to_i > 1 ? 1 : 3
    else
      fold_limit
    end
  end

  # число подгружаемых комментариев из click-loader блока
  def fold_limit
    if preview?
      10
    else
      20
    end
  end

  # посты топика
  def comments
    comments = object
      .comments
      .with_viewed(h.current_user)
      .limit(comments_limit)

    (reviews_only? ? comments.reviews : comments)
      .decorate
      .to_a
      .reverse
  end

  # тег топика
  def tag
    return nil if linked.nil? || review? || contest?

    if linked.kind_of? Review
      h.localized_name linked.target
    else
      h.localized_name linked if linked.respond_to?(:name) && linked.respond_to?(:russian)
    end
  end

  # адрес заголовка топика
  def url
    preview? ? h.topic_url(object) : h.profile_url(user)
  end

  # адрес текста топика
  def body_url
    h.entry_body_url object
  end

  # адрес прочих комментариев топика
  def comments_url
    h.fetch_comments_url(
      comment_id: comments.first.id,
      topic_type: topic_type,
      topic_id: object.id,
      skip: 'SKIP',
      limit: fold_limit,
      review: reviews_only? ? 'review' : nil
    )
  end

  def edit_url
    if review?
      h.send "edit_#{linked.target_type.downcase}_review_url", linked.target, linked
    else
      h.edit_topic_url object
    end
  end

  def destroy_url
    if review?
      h.send "#{linked.target_type.downcase}_review_url", linked.target, linked
    else
      h.topic_path object
    end
  end

  # текст для свёрнутых комментариев
  def show_hidden_comments_text
    num = [folded_comments, fold_limit].min
    comment_word = if reviews_only?
      i18n_i 'summary', num, :accusative
    else
      i18n_i 'comment', num, :accusative
    end

    i18n_t 'show_hidden_comments_text_html' do |options|
      options[:comment_count] = num
      options[:comment_word] = comment_word

      options[:out_of_total_comments] = if folded_comments > fold_limit
        "#{i18n_p('out_of').downcase} #{folded_comments}"
      end
    end.html_safe
  end

  def new_comment
    Comment.new user: h.current_user, commentable: object, review: reviews_only?
  end

  # переключение на отображение отзывов
  def reviews_only!
    @force_reviews = true
  end

  def reviews_only?
    !!@force_reviews
  end

  # переключение на отображение в режиме превью
  def preview_mode!
    @preview_mode = true
  end
  def topic_mode!
    @preview_mode = false
  end
  def preview?
    @preview_mode.nil? ? h.params[:action] != 'show' : @preview_mode
  end

  # канал faye для топика
  def faye_channel
    ["topic-#{id}"].to_json
  end

private
  # для адреса подгрузки комментариев
  def topic_type
    Entry.name
  end
end
