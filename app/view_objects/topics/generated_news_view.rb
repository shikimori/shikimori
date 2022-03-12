class Topics::GeneratedNewsView < Topics::View
  instance_cache :decorated_linked

  def container_classes
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
    if is_preview
      super
    else
      i18n_t "titles.#{topic.action}", value: topic.value
    end
  end

  def render_body
    h.content_tag :div, render_linked, class: 'b-catalog-entry-embedded'
  end

  def poster_in_header?
    false
  end

  def decorated_linked
    topic.linked.decorate
  end

private

  def render_linked
    h.render(
      decorated_linked,
      cover_title: :none,
      cover_notice: :none,
      content_by: :block,
      content_title: :none,
      content_text: :none
    )
  end
end
