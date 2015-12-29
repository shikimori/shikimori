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
    Rails.cache.fetch([:forums, :v9, Entry.last.id], expires_in: 2.weeks) do
      Forum.visible.map { |forum| decorate forum, false } +
        Array(decorate Forum::NEWS_FORUM, true) +
        Array(decorate Forum.find_by_permalink('reviews'), true) +
        Array(build Forum.find_by_permalink('contests'), true) +
        Array(decorate Forum::MY_CLUBS_FORUM, true) +
        Array(decorate Forum.find_by_permalink('clubs'), true)
    end
  end

  def decorate forum, is_special
    size = is_special ? nil : forum_size(forum)
    ForumForList.new forum, is_special, size
  end

  def forum_size forum
    TopicsQuery
      .new(current_user)
      .by_forum(forum)
      .where('generated = false or (generated = true and comments_count > 0)')
      .size
  end

  def current_user
    h.current_user rescue NoMethodError
  end
end
