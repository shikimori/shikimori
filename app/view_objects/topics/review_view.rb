class Topics::ReviewView < Topics::UserContentView
  delegate :db_entry, :body, to: :review
  delegate :faye_channels, to: :topic

  def container_classes
    if review_author_details?
      super %w[b-review-topic is-review_review_author_details]
    else
      super 'b-review-topic'
    end
  end

  def need_trucation?
    minified?
  end

  def review_author_details?
    (preview? && minified?) || !preview?
  end

  def cleanup_body_tags?
    minified?
  end

  def action_tag
    super [
      OpenStruct.new(
        type: 'review',
        text: i18n_i('review', :one)
      ),
      OpenStruct.new(
        type: "review-#{review.opinion}",
        text: review.opinion_text.downcase
      )
    ]
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

  def review
    @topic.linked
  end

  def dynamic_type
    review_author_details? ? :review : super
  end

  def footer_vote?
    !minified?
  end

  def cache_key
    super review_author_details?
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
end
