class Topics::ContestStatusView < Topics::NewsView
  def container_classes
    super 'b-contest_status-topic'
  end

  def need_trucation?
    preview?
  end

  def show_inner?
    true
  end

  def poster_image_url is_2x
    topic.user.avatar_url is_2x ? 80 : 48
  end

  def html_body
    h.render(
      partial: "topics/contests/#{topic.action}",
      locals: { contest: topic.linked },
      formats: :html # must add format because topic also is rendered in rss xml
    )
  end

  def action_tag
    super OpenStruct.new(
      type: 'contest',
      text: i18n_i('contest', :one)
    )
  end
end
