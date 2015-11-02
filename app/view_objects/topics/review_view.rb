class Topics::ReviewView < Topics::View
  def container_class
    super 'b-review-topic'
  end

  def minified?
    is_preview || is_mini
  end

  def show_body?
    true
  end

  def action_tag
    OpenStruct.new(
      type: 'review',
      text: i18n_i('review', :one)
    ) if is_preview
  end

  def offtopic_tag
    if topic.linked.rejected?
      I18n.t 'markers.offtopic'
    end
  end

  def topic_title
    if !is_preview
      topic.user.nickname
    else
      h.localized_name topic.linked.target
    end
    # if is_preview
      # h.localized_name topic.linked.target
      # # i18n_t(
        # # "title.#{topic.linked.target_type.downcase}",
        # # target_name: h.h(h.localized_name(topic.linked.target))
      # # ).html_safe
    # else
      # super
    # end
  end

  def render_body
    render_results + render_stars + super
  end

  def vote_results?
    topic.linked.votes_count > 0
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
    topic.linked.text
  end

  def render_stars
    h.render 'reviews/stars', review: topic.linked,
      with_music: topic.linked.entry.kind_of?(Anime)
  end

  def render_results
    h.render 'topics/reviews/votes_count', review: topic.linked
  end
end
