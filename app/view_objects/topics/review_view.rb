class Topics::ReviewView < Topics::ArticleView
  def container_class
    super('b-review-topic').gsub('b-article-topic', '').gsub('  ', ' ').trim
  end

  def action_tag
    OpenStruct.new(
      type: 'review',
      text: i18n_i('review', :one)
    )
  end

  def topic_title
    if preview?
      review.target.name
    else
      i18n_t(
        "title.#{review.target_type.downcase}",
        target_name: h.h(h.localized_name(review.target))
      ).html_safe
    end
  end

  def topic_title_html
    if preview?
      h.localization_span review.target
    else
      topic_title
    end
  end

  def render_body
    preview? ? html_body_truncated : (stars_html + html_body)
  end

  def vote_results?
    review.votes_count.positive?
  end

private

  def stars_html
    h.render 'reviews/stars',
      review: review,
      with_music: review.entry.is_a?(Anime)
  end

  def review
    @topic.linked
  end
end
