class Topics::View < ViewObjectBase
  vattr_initialize :topic, :is_preview

  instance_cache :comments, :urls

  def ignored?
    h.user_signed_in? && h.current_user.ignores?(topic.user)
  end

  def container_class css = ''
    [css, ('b-topic-preview' if is_preview)].compact.join ' '
  end

  def show_body?
    is_preview || !topic.generated? || topic.contest?
  end

  def topic_title
    if is_preview
      topic.title
    else
      topic.user.nickname
    end
    # if !preview?
      # user.nickname
    # elsif topic.generated_news? || object.class == AniMangaComment
      # h.localized_name object.linked
    # elsif contest? || object.respond_to?(:title)
      # object.title
    # else
      # object.name
    # end
  end

  def render_body
    html_body
  end

  # картинка топика(аватарка автора)
  def poster is_2x
    if topic.linked && is_preview
      ImageUrlGenerator.instance.url(
        (topic.review? ? topic.linked.target : topic.linked), is_2x ? :x96 : :x48
      )
    else
      topic.user.avatar_url(is_2x ? 80 : 48)
    end
  end

  def comments
    Topics::Comments.new(
      topic: topic,
      only_summaries: false,
      is_preview: is_preview
    )
  end

  def urls
    Topics::Urls.new topic, is_preview
  end

  def faye_channel
    ["topic-#{topic.id}"].to_json
  end

  def subscribed?
    current_user.subscribed? topic
  end

  def author_in_header?
    true
  end

  def author_in_footer?
    is_preview && (topic.news? || topic.review?) &&
      (!author_in_header? || poster(false) != user.avatar_url(48))
  end

  def html_body
    Rails.cache.fetch body_cache_key, expires_in: 2.weeks do
      BbCodeFormatter.instance.format_comment topic.body
    end
  end

private

  def body
    topic.body
  end

  def body_cache_key
    [topic, topic.linked, h.russian_names_key, 'body']
  end
end
