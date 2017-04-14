class Topics::ClubPageView < Topics::View
  def container_class
    super 'b-club_page-topic'
  end

  def html_body
    Rails.cache.fetch [topic.linked, :html] do
      BbCodeFormatter.instance.format_comment(topic.linked.text)
    end
  end
end
