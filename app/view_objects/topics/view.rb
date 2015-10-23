class Topics::View < ViewObjectBase
  vattr_initialize :topic

  dsl_attribute :is_preview, false
  instance_cache :comments, :urls

  def ignored?
    h.user_signed_in? && h.current_user.ignores?(topic.user)
  end

  def review_preview?
    false
  end

  def css_classes
    classes = []

    classes.push 'b-review' if topic.review?
    classes.push 'b-cosplay' if topic.cosplay?
    classes.push 'b-generated_news' if topic.generated_news?

    classes
  end

  def show_body?
    !topic.generated? || topic.contest? || topic.review?
  end

  def topic_title
    if topic.review?
      i18n_t(
        "title.review.#{topic.linked.target_type.downcase}",
        target_name: h.h(h.localized_name(topic.linked.target))
      ).html_safe
    else
      fail ArgumentError
    end
    # if !preview?
      # user.nickname
    # elsif generated_news? || object.class == AniMangaComment
      # h.localized_name object.linked
    # elsif contest? || object.respond_to?(:title)
      # object.title
    # else
      # object.name
    # end
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
  def poster is_2x
    if topic.linked
      ImageUrlGenerator.instance.url(
        (topic.review? ? topic.linked.target : topic.linked), is_2x ? :x96 : :x48
      )
    else
      topic.user.avatar_url(is_2x ? 48 : 80)
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
end
