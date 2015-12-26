class Forums::List  < ViewObjectBase
  include Enumerable

  instance_cache :all

  def each
    forums.each { |forum| yield forum }
  end

  def self.defaults
    new.map(&:id) - [Forum.find_by_permalink('clubs').id]
  end

private

  def forums
    Rails.cache.fetch([:forums, Entry.last.id], expires_in: 2.weeks) do
      Forum.visible.map { |forum| build forum, false } +
        Array(build Forum.find_by_permalink('reviews'), true) +
        # Array(build Forum::NEWS_FORUM, true) +
        Array(build Forum::MY_CLUBS_FORUM, true) +
        Array(build Forum.find_by_permalink('clubs'), true)
    end
  end

  def build forum, is_special
    size = TopicsQuery
      .new(h.current_user)
      .by_forum(forum)
      .where('comments_count > 0')
      .size unless is_special

    OpenStruct.new(
      name: forum.name,
      url: h.forum_topics_url(forum),
      id: forum.id,
      size: size,
      is_special: is_special
    )
  end
end
