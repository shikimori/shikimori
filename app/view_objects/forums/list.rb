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
    ForumForList.new forum, is_special
  end
end
