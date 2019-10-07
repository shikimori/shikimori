class Topics::ContestStatusView < Topics::NewsView
  def container_class
    super 'b-contest_status-topic'
  end

  def minified?
    true
  end

  def show_inner?
    true
  end

  def poster is_2x
    topic.user.avatar_url(is_2x ? 80 : 48)
  end

  def html_body
    h.render(
      partial: "topics/contests/#{topic.action}",
      locals: { contest: topic.linked },
      formats: :html # must add format because topic also is rendered in rss xml
    )
  end
end
