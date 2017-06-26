class Topics::NewsView < Topics::View
  def container_class css = nil
    super ['b-news-topic', css]
  end

  # def minified?
    # is_preview || is_mini
  # end

  def topic_title
    topic.title
  end

  def topic_title_html
    topic_title
  end

  def action_tag
    OpenStruct.new(
      type: 'news',
      text: i18n_i('news', :one)
    )
  end
end
