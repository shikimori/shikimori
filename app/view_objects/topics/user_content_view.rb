class Topics::UserContentView < Topics::View
  def show_body?
    true
  end

  def changed_at
    linked = @topic.linked

    return unless linked&.updated_at && linked&.created_at
    return if linked.updated_at - linked.created_at < 1.hour
    return if format_date(linked.updated_at) ==
      format_date(linked.created_at)

    linked.updated_at
  end

  def footer_vote?
    !preview?
  end
end
