class Topics::NewsView < Topics::View
  def container_classes additional = []
    super(
      ['b-news-topic', *additional]
    )
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

  def action_tag additional = []
    super(
      [OpenStruct.new(type: 'news', text: i18n_i('news', :one))] +
        Array(additional)
    )
  end
end
