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

  def changed_at # rubocop:disable all
    changed_at = @topic.linked.respond_to?(:changed_at) && linked.changed_at
    return changed_at if changed_at

    updated_at = @topic.linked&.updated_at
    created_at = @topic.linked&.created_at

    return unless updated_at && created_at
    return if updated_at - created_at < 1.hour
    return if format_date(updated_at) ==
      format_date(created_at)
    return if h.time_ago_in_words(updated_at, nil, true) ==
      h.time_ago_in_words(created_at, nil, true)

    updated_at
  end

  def offtopic_tag
    if @topic.linked.respond_to?(:rejected?) && @topic.linked.rejected?
      I18n.t 'markers.offtopic'
    end
  end
end
