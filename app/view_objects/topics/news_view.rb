class Topics::NewsView < Topics::View
  def container_class css = nil
    super ['b-news-topic', css]
  end

  def show_source?
    decomposed_body.source.present?
  end

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
