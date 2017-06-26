class Topics::ContestStatusView < Topics::NewsView
  def poster is_2x
    topic.user.avatar_url(is_2x ? 80 : 48)
  end

  def how_body?
    true
  end
end
