class Topics::GeneratedNewsView < Topics::View
  def container_class
    super 'b-generated_news'
  end

  def action_tag
    if topic.episode?
      "#{topic.action_text} #{topic.value}"
    else
      topic.action_text
    end
  end


  def render_body
    render_linked
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
