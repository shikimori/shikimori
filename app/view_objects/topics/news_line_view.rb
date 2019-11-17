class Topics::NewsLineView < Topics::View
  instance_cache :view
  delegate :urls,
    :poster,
    :topic_title,
    :topic_title_html,
    to: :view

  def container_classes additional = []
    ['b-news_line-topic', *additional]
  end

  def view
    Topics::TopicViewFactory.new(@is_preview, @is_mini).build @topic
  end

  def action_tag
    view.action_tag || OpenStruct.new(
      type: 'other',
      text: i18n_i('topic', :one)
    )
  end
end
