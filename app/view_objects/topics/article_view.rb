class Topics::ArticleView < Topics::UserContentView
  def container_classes additional = []
    super(
      ['b-article-topic', *additional]
    )
  end

  def need_trucation?
    true
  end

  def minified?
    is_preview || is_mini
  end

  def action_tag
    OpenStruct.new(
      type: 'article',
      text: i18n_i('article', :one)
    )
  end

  def offtopic_tag
    I18n.t 'markers.offtopic' if article.rejected?
  end

  # def topic_title
  #   if preview?
  #     article.target.name
  #   else
  #     i18n_t(
  #       "title.#{article.target_type.downcase}",
  #       target_name: h.h(h.localized_name(article.target))
  #     ).html_safe
  #   end
  # end
  #
  # def topic_title_html
  #   if preview?
  #     h.localization_span article.target
  #   else
  #     topic_title
  #   end
  # end

  def render_body
    preview? ? html_body_truncated : html_body
  end

  def read_more_link?
    preview? || minified?
  end

  def html_body
    text = article.text

    if preview? || minified?
      text = text
        .gsub(%r{\[/?center\]}mix, '')
        .gsub(%r{\[(img|poster|image).*?\].*\[/\1\]}, '')
        .gsub(/\[(poster|image)=.*?\]/, '')
        .gsub(%r{\[spoiler.*?\]\s*\[/spoiler\]}, '')
        .strip
    end

    BbCodes::EntryText.call text, article
  end

  def footer_vote?
    false
  end

private

  def body
    article.text
  end

  def article
    @topic.linked
  end
end
