class Topics::GeneratedNewsView < Topics::View
  def container_class
    super 'b-generated_news-topic'
  end

  def minified?
    false
  end

  def action_tag
    OpenStruct.new(
      type: topic.action,
      text: topic.episode? ?
        "#{topic.action_text} #{topic.value}" :
        topic.action_text
    )
  end

  def render_body
    "<div class='b-catalog-entry-embedded'>#{render_linked}</div>"
  end

  def author_in_header?
    false
  end

private

  def render_linked
    h.render(topic.linked.decorate,
      cover_title: :none,
      cover_notice: :none,
      content_by: :block,
      content_title: :none,
      content_text: :none
    )
  end
end
