class Topics::Query < QueryObjectBase
  def self.fetch user, is_censored_forbidden
    scope = Topic
      .includes(:forum, :user, :linked)
      .order(updated_at: :desc)

    new(
      is_censored_forbidden ?
        scope.where(is_censored: false) :
        scope
    ).lazy_filter { |topic| Topic::AccessPolicy.allowed? topic, user }
  end

  def by_forum forum, user, is_censored_forbidden
    chain Topics::ForumQuery.call(
      scope: except_episodes(@scope, forum),
      forum: forum,
      user: user,
      is_censored_forbidden: is_censored_forbidden
    )
  end

  def by_linked linked
    if linked.is_a? Club
      chain @scope
        .where(
          Topics::ForumQuery::SPECIFIC_CLUBS_QUERY,
          club_ids: linked.id,
          club_page_ids: linked.pages.pluck(:id)
        )
    elsif linked
      chain @scope.where(linked: linked)
    else
      self
    end
  end

  def search phrase, forum, user
    chain Topics::SearchQuery.call(
      scope: @scope,
      phrase: phrase,
      forum: forum,
      user: user
    )
  end

  def as_views is_preview, is_mini
    lazy_map do |topic|
      Topics::TopicViewFactory.new(is_preview, is_mini).build topic
    end
  end

private

  def except_episodes scope, forum
    if forum == Forum::UPDATES_FORUM || forum&.id == Forum::NEWS_ID
      scope.wo_episodes
    else
      scope.where.not(updated_at: nil)
    end
  end
end
