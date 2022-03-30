class Topics::ClubPageView < Topics::View
  def container_classes
    super 'b-club_page-topic'
  end

  def poster is_2x
    @topic.user.avatar_url is_2x ? 80 : 48
  end

  def show_inner?
    true
  end

  def deletable?
    false
  end

  def html_body
    return super if preview?

    Rails.cache.fetch CacheHelperInstance.cache_keys(topic.linked, :html) do
      BbCodes::Text.call(topic.linked.text)
    end
  end
end
