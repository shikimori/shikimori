class Topics::NewsView < Topics::View
  def container_class
    super 'b-news-topic'
  end

  def minified?
    is_preview || is_mini
  end

  def topic_title
    topic.title
  end

  def html_footer
    BbCodeFormatter.instance.format_comment topic.appended_text
  end

  def action_tag
    i18n_i 'news', :one
  end
end
