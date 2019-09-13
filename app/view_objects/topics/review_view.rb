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

  def read_more_link?
    preview? || minified?
  end

  def html_body
    text = review.text

    if preview? || minified?
      text = text
        .gsub(%r{\[/?center\]}mix, '')
        .gsub(%r{\[(img|poster|image).*?\].*\[/\1\]}, '')
        .gsub(/\[(poster|image)=.*?\]/, '')
        .gsub(%r{\[spoiler.*?\]\s*\[/spoiler\]}, '')
        .strip
    end

    BbCodes::EntryText.call text, review
  end

private

  def body
    review.text
  end

  def stars_html
    h.render 'reviews/stars',
      review: review,
      with_music: review.entry.is_a?(Anime)
  end

  def review
    @topic.linked
  end
end
