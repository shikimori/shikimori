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
    I18n.t 'markers.offtopic' if topic.linked.rejected?
  end

  # rubocop:disable AbcSize
  def topic_title
    if !is_preview
      i18n_t(
        "title.#{topic.linked.target_type.downcase}",
        target_name: h.h(h.localized_name(topic.linked.target))
      ).html_safe
    else
      h.localized_name topic.linked.target
    end
  end
   # rubocop:enable AbcSize

  def render_body
    render_results + render_stars + super
  end

  def vote_results?
    topic.linked.votes_count > 0
  end

  def html_body
    if is_preview || is_mini
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
    BbCodeFormatter.instance.format_description(
      topic.linked.text, topic.linked
    )
  end

  def body
    topic.linked.text
  end

  def render_stars
    h.render 'reviews/stars',
      review: topic.linked,
      with_music: topic.linked.entry.is_a?(Anime)
  end

  def render_results
    h.render 'topics/reviews/votes_count', review: topic.linked
  end
end
