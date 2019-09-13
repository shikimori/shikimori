class Topics::GeneratedNewsView < Topics::View
  def container_class
    super 'b-generated_news-topic'
  end

  def minified?
    false
  end

  def status_line?
    false
  end

  def action_tag
    OpenStruct.new type: topic.action, text: topic.title.downcase
  end

  def poster_title
    topic.linked.name
  end

  def poster_title_html
    h.localization_span topic.linked
  end

  def topic_title
    if !is_preview
      i18n_t "titles.#{topic.action}", value: topic.value
    else
      super
    end
  end

  def render_body
    h.content_tag :div, render_linked, class: 'b-catalog-entry-embedded'
  end

  def author_in_header?
    false
  end

private

  def render_linked
    h.render(
      topic.linked.decorate,
      cover_title: :none,
      cover_notice: :none,
      content_by: :block,
      content_title: :none,
      content_text: :none
    )
  end
end
