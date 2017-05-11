class Topics::ClubPageView < Topics::View
  def container_class
    super 'b-club_page-topic'
  end

  def poster is_2x
    @topic.user.avatar_url is_2x ? 80 : 48
  end

  def show_body?
    true
  end

  def html_body
    return super if preview?

    Rails.cache.fetch [topic.linked, :html] do
      BbCodeFormatter.instance.format_comment(topic.linked.text)
    end
  end
end
