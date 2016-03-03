class TopicsQuery < ChainableQueryBase
  pattr_initialize :user

  FORUMS_QUERY = 'forum_id in (:user_forums)'
  MY_CLUBS_QUERY = "(
    type = #{Entry.sanitize Topics::EntryTopics::ClubTopic.name} and
    #{Entry.table_name}.linked_id in (:user_clubs)
  )"
  NEWS_QUERY = "(
    type = '#{Topics::NewsTopic.name}' and
    generated = false
  ) or (
    type = '#{Topics::EntryTopics::CosplayGalleryTopic.name}' and
    generated = true
  )"

  def initialize user
    @user = user
    @relation = prepare_query

    except_hentai
    except_ignored if @user
  end

  def by_forum forum
    case forum && forum.permalink
      when nil
        if @user
          user_forums
        else
          where_not type: Topics::EntryTopics::ClubTopic.name
        end

      when 'reviews'
        where forum_id: forum.id
        order! created_at: :desc

      when 'clubs'
        joins "left join clubs on clubs.id=linked_id and linked_type='Club'"
        where forum_id: forum.id
        where "(linked_id in (:user_clubs)) or clubs.is_censored = false",
          user_clubs: @user ? @user.club_roles.pluck(:club_id) : []

      when Forum::NEWS_FORUM.permalink
        where NEWS_QUERY
        order! created_at: :desc

      when Forum::UPDATES_FORUM.permalink
        where type: [Topics::NewsTopic.name]
        where generated: true
        order! created_at: :desc

      when Forum::MY_CLUBS_FORUM.permalink
        where MY_CLUBS_QUERY,
          user_clubs: @user ? @user.club_roles.pluck(:club_id) : []

      else
        where forum_id: forum.id
    end

    except_episodes forum
    except_ignored if @user

    self
  end

  def by_linked linked
    return self unless linked
    where linked: linked
    self
  end

  def as_views is_preview, is_mini
    result.map do |topic|
      Topics::TopicViewFactory.new(is_preview, is_mini).build topic
    end
  end

private

  def prepare_query
    Entry
      .with_viewed(@user)
      .includes(:forum, :user)
      .order(updated_at: :desc)
  end

  def user_forums
    if @user.preferences.forums.include? Forum::MY_CLUBS_FORUM.permalink
      where(
        "#{FORUMS_QUERY} or #{MY_CLUBS_QUERY}",
        user_forums: @user.preferences.forums.map(&:to_i),
        user_clubs: @user.club_roles.pluck(:club_id)
      )
    else
      where FORUMS_QUERY, user_forums: @user.preferences.forums.map(&:to_i)
    end
  end

  def except_episodes forum
    if forum == Forum::NEWS_FORUM || forum == Forum::UPDATES_FORUM
      @relation = @relation.wo_episodes
    else
      where_not updated_at: nil
    end
  end

  def except_hentai
    joins "left join animes on animes.id=linked_id and linked_type='Anime'"
    where 'animes.id is null or animes.censored=false'
  end

  def except_ignored
    # joins "left join topic_ignores on
      # topic_ignores.user_id = #{User.sanitize @user.id}
      # and topic_ignores.topic_id = entries.id"
    # where 'topic_ignores.id is null'
    where_not id: @user.topic_ignores.map(&:topic_id)
  end
end
