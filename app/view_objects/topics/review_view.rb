class Topics::ReviewView < Topics::UserContentView
  def container_class
    super 'b-review-topic'
  end

  def need_trucation?
    true
  end

  def minified?
    is_preview || is_mini
  end

  def action_tag
    OpenStruct.new(
      type: 'review',
      text: i18n_i('review', :one)
    )
  end

  def offtopic_tag
    I18n.t 'markers.offtopic' if review.rejected?
  end

  # rubocop:disable AbcSize
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
   # rubocop:enable AbcSize

  def topic_title_html
    if preview?
      h.localization_span review.target
    else
      topic_title
    end
  end

  def render_body
    preview? ? html_body_truncated : (results_html + stars_html + html_body)
  end

  def vote_results?
    review.votes_count > 0
  end

  def read_more_link?
    preview? || minified?
  end

  def html_body
    if preview? || minified?
      format_body
        .gsub(/<img.*?>/, '')
        .strip
        .gsub(/\A<center> \s* <\/center>/, '')
        .html_safe
    else
      format_body
    end
  end

private

  def format_body
    BbCode.instance.format_description(
      review.text, review
    )
  end

  def body
    review.text
  end

  def stars_html
    h.render 'reviews/stars',
      review: review,
      with_music: review.entry.is_a?(Anime)
  end

  def results_html
    h.render 'topics/reviews/votes_count', review: review
  end

  def review
    @topic.linked
  end
end
