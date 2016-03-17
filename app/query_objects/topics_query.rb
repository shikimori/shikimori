class TopicsQuery < QueryObjectBase
  FORUMS_QUERY = 'forum_id in (:user_forums)'
  MY_CLUBS_QUERY = <<SQL
    (
      type = #{Entry.sanitize Topics::EntryTopics::ClubTopic.name} and
      #{Entry.table_name}.linked_id in (:user_clubs)
    )
SQL
  NEWS_QUERY = <<SQL
    (
      type = '#{Topics::NewsTopic.name}' and
      generated = false
    ) or (
      type = '#{Topics::EntryTopics::CosplayGalleryTopic.name}' and
      generated = true
    )
SQL
  CLUBS_JOIN = "left join clubs on clubs.id=linked_id and linked_type='Club'"

  def self.fetch user
    query = new Entry
      .with_viewed(user)
      .includes(:forum, :user)
      .order(updated_at: :desc)

    query.except_hentai.except_ignored(user)
  end

  def by_forum forum, user, is_censored_forbidden
    new_scope = except_episodes(@scope, forum)
    chain forum_scope(new_scope, forum, user, is_censored_forbidden)
  end

  def by_linked linked
    if linked
      chain @scope.where(linked: linked)
    else
      self
    end
  end

  def except_ignored user
    if user
      chain @scope.where.not id: user.topic_ignores.map(&:topic_id)
    else
      self
    end
  end

  def except_hentai
    chain @scope
      .joins("left join animes on animes.id=linked_id and linked_type='Anime'")
      .where('animes.id is null or animes.censored=false')
  end

  def as_views is_preview, is_mini
    mapped_scope = MappedCollection.new @scope do |topic|
      Topics::TopicViewFactory.new(is_preview, is_mini).build topic
    end

    chain mapped_scope
  end

private

  def except_episodes scope, forum
    if forum == Forum::NEWS_FORUM || forum == Forum::UPDATES_FORUM
      scope.wo_episodes
    else
      scope.where.not(updated_at: nil)
    end
  end

  # TODO: refactor to standalone class
  def forum_scope scope, forum, user, is_censored_forbidden
    case forum && forum.permalink
      when nil
        if user
          user_forums scope, user
        else
          scope.where.not(type: Topics::EntryTopics::ClubTopic.name)
        end

      when 'reviews'
        scope
          .where(forum_id: forum.id)
          .except(:order)
          .order(created_at: :desc)

      when 'clubs'
        new_scope = scope.where(forum_id: forum.id, linked_type: Club.name)

        if is_censored_forbidden
          new_scope
            .joins(CLUBS_JOIN)
            .where(
              "(linked_id in (:user_clubs)) or clubs.is_censored = false",
              user_clubs: user ? user.club_roles.pluck(:club_id) : []
            )
        else
          new_scope
        end

      when Forum::NEWS_FORUM.permalink
        scope
          .where(NEWS_QUERY)
          .except(:order)
          .order(created_at: :desc)

      when Forum::UPDATES_FORUM.permalink
        scope
          .where(type: [Topics::NewsTopic.name], generated: true)
          .except(:order)
          .order(created_at: :desc)

      when Forum::MY_CLUBS_FORUM.permalink
        scope
          .where(
            MY_CLUBS_QUERY,
            user_clubs: user ? user.club_roles.pluck(:club_id) : []
          )

      else
        scope
          .where(forum_id: forum.id)
    end
  end

  def user_forums scope, user
    if user.preferences.forums.include? Forum::MY_CLUBS_FORUM.permalink
      scope.where(
        "#{FORUMS_QUERY} or #{MY_CLUBS_QUERY}",
        user_forums: user.preferences.forums.map(&:to_i),
        user_clubs: user.club_roles.pluck(:club_id)
      )
    else
      scope.where(FORUMS_QUERY, user_forums: user.preferences.forums.map(&:to_i))
    end
  end
end
