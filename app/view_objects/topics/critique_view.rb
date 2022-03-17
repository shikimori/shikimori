class Topics::CritiqueView < Topics::UserContentView
  def container_classes
    super 'b-critique-topic'
  end

  def need_trucation?
    preview? || minified?
  end

  def action_tag
    OpenStruct.new(
      type: 'critique',
      text: i18n_i('critique', :one)
    )
  end

  def topic_title
    if preview?
      critique.target.name
    else
      i18n_t(
        "title.#{critique.target_type.underscore}",
        target_name: h.h(h.localized_name(critique.target))
      ).html_safe
    end
  end

  def topic_title_html
    if preview?
      h.localization_span critique.target
    else
      topic_title
    end
  end

  def html_body
    stars_html + super
  end

  def vote_results?
    critique.votes_count.positive?
  end

  def poster_in_header?
    !preview?
  end

private

  def body
    critique.text
  end

  def stars_html
    h.render(
      partial: 'animes/critiques/stars',
      locals: {
        critique: critique,
        is_preview: preview?
      },
      formats: :html
    )
  end

  def critique
    @topic.linked
  end
end
