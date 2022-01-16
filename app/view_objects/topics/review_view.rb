class Topics::ReviewView < Topics::UserContentView
  delegate :db_entry, to: :review

  def topic_title
    if preview?
      review.target.name
    else
      i18n_t(
        "title.#{db_entry.class.name.underscore}",
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

private

  def body
    review.text
  end

  def review
    @topic.linked
  end
end
