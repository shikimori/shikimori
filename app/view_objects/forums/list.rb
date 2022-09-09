class Forums::List < ViewObjectBase
  include Enumerable
  instance_cache :decorated_forums, :static_forums

  pattr_initialize [:with_forum_size]

  def each &block
    cached_forums.each(&block)
  end

private

  def cached_forums
    return decorated_forums unless @with_forum_size

    Rails.cache.fetch([:forums, :v3, Topic.last&.id], expires_in: 2.weeks) do
      decorated_forums
    end
  end

  def decorated_forums
    public_forums + static_forums
  end

  def public_forums
    Forum
      .public
      .reject { |v| static_forums.find { |vv| vv.permalink == v.permalink } }
      .map { |forum| decorate forum, false }
  end

  def static_forums
    [
      decorate(Forum.news, true),
      decorate(Forum.find_by_permalink('critiques'), true), # rubocop:disable DynamicFindBy
      decorate(Forum.find_by_permalink('reviews'), true), # rubocop:disable DynamicFindBy
      decorate(Forum.find_by_permalink('contests'), true), # rubocop:disable DynamicFindBy
      decorate(Forum.find_by_permalink('collections'), true), # rubocop:disable DynamicFindBy
      decorate(Forum.find_by_permalink('articles'), true), # rubocop:disable DynamicFindBy
      decorate(Forum::MY_CLUBS_FORUM, true),
      decorate(Forum.find_by_permalink('clubs'), true) # rubocop:disable DynamicFindBy
    ]
  end

  def decorate forum, is_special
    size = is_special || !@with_forum_size ? nil : forum_size(forum)
    ForumForList.new forum, is_special, size
  end

  def forum_size forum
    Topics::Query.fetch(h.current_user, h.censored_forbidden?)
      .by_forum(forum, current_user, censored_forbidden?)
      .where('generated = false or (generated = true and comments_count > 0)')
      .size
  end

  def current_user
    h.current_user
  rescue NoMethodError
    nil
  end

  def censored_forbidden?
    h.respond_to?(:censored_forbidden?) ? h.censored_forbidden? : false
  end
end
