class Topics::ReviewView < Topics::View
  vattr_initialize :topic, :is_preview, :is_single_lined

  def container_class
    super 'b-review'
  end

  def show_body?
    true
  end

  def topic_title
    return super unless is_preview

    i18n_t(
      "title.#{topic.linked.target_type.downcase}",
      target_name: h.h(h.localized_name(topic.linked.target))
    ).html_safe
  end

  def render_body
    render_stars + super
  end

  def vote_results?
    topic.linked.votes_count > 0
  end

  def single_lined_preview?
    is_preview && is_single_lined
  end

  def html_body
    Rails.cache.fetch body_cache_key, expires_in: 2.weeks do
      BbCodeFormatter.instance.format_description(
        topic.linked.text, topic.linked
      )
    end
  end

private

  def body
    linked.text
  end

  def render_stars
    h.render('reviews/stars',
      review: topic.linked,
      with_music: topic.linked.entry.kind_of?(Anime)
    )
  end
end
