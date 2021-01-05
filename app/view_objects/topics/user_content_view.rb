class Topics::UserContentView < Topics::View
  def generated?
    false
  end

  def show_inner?
    true
  end

  def need_trucation?
    false
  end

  def unpublished?
    @topic.linked.respond_to?(:unpublished?) && @topic.linked.unpublished?
  end

  def changed_at # rubocop:disable AbcSize
    linked = @topic.linked

    return unless linked&.updated_at && linked&.created_at
    return if linked.updated_at - linked.created_at < 1.hour
    return if format_date(linked.updated_at) ==
      format_date(linked.created_at)
    return if h.time_ago_in_words(linked.updated_at, nil, true) ==
      h.time_ago_in_words(linked.created_at, nil, true)

    linked.updated_at
  end

  def offtopic_tag
    if @topic.linked.respond_to?(:rejected?) && @topic.linked.rejected?
      I18n.t 'markers.offtopic'
    end
  end

  def footer_vote?
    !preview?
  end
end
