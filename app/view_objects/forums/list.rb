class Forums::List  < ViewObjectBase
  include Enumerable

  instance_cache :all

  def each
    forums.each { |forum| yield forum }
  end

private

  def forums
    Rails.cache.fetch([:forums, Entry.last.id], expires_in: 2.weeks) { all }
  end

  def all
    Forum.visible.map do |forum|
      size = TopicsQuery
        .new(h.current_user)
        .by_forum(forum)
        .where('comments_count > 0')
        .size

      OpenStruct.new(
        name: forum.name,
        url: h.forum_topics_url(forum),
        id: forum.id || forum.permalink,
        size: size
      )
    end
  end
end
