class Topics::ReviewView < Topics::UserContentView
  delegate :db_entry, :body, to: :review

  def container_classes
    super 'b-review-topic'
  end

  def need_trucation?
    preview? || minified?
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

  def topic_title
    if preview?
      db_entry.name
    else
      i18n_t(
        "title.#{db_entry.class.name.underscore}",
        target_name: h.h(h.localized_name(db_entry))
      ).html_safe
    end
  end

  def topic_title_html
    if preview?
      h.localization_span db_entry
    else
      topic_title
    end
  end

  def vote_results?
    review.votes_count.positive?
  end

private

  def stars_html
    h.render(
      partial: 'animes/reviews/stars',
      locals: {
        review: review,
        with_music: review.entry.is_a?(Anime)
      },
      formats: :html
    )
  end

  def review
    @topic.linked
  end
end
