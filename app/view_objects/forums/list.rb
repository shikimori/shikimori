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
    Rails.cache.fetch(cache_key, expires_in: 2.weeks) do
      Forum.visible.map { |forum| decorate forum, false } + [
        decorate(Forum::NEWS_FORUM, true),
        decorate(Forum.find_by_permalink('reviews'), true),
        decorate(Forum.find_by_permalink('contests'), true),
        decorate(Forum::MY_CLUBS_FORUM, true),
        decorate(Forum.find_by_permalink('clubs'), true)
      ]
    end
  end

  def decorate forum, is_special
    size = is_special ? nil : forum_size(forum)
    ForumForList.new forum, is_special, size
  end

  def forum_size forum
    TopicsQuery.fetch(current_user)
      .by_forum(forum, current_user, censored_forbidden?) # может не быть при регистрации через соц сеть и первичном заполнении профиля
      .where('generated = false or (generated = true and comments_count > 0)')
      .size
  end

  def current_user
    h.current_user
  rescue NoMethodError
    nil
  end

  def cache_key
    [:forums, :v3, Entry.last.id]
  end

  def censored_forbidden?
    h.respond_to?(:censored_forbidden?) ? h.censored_forbidden? : false
  end
end
