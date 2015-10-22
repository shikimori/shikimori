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

  def faye_channel
    ["topic-#{topic.id}"].to_json
  end

  def show_body?
    !topic.generated? || topic.contest? || topic.review?
  end

  def comments
    Topics::Comments.new(
      topic: topic,
      only_summaries: false,
      is_preview: is_preview
    )
  end

  def subscribed?
    current_user.subscribed? topic
  end

  def urls
    Topics::Urls.new topic, is_preview
  end
end
