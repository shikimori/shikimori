class TopicsQuery < ChainableQueryBase
  pattr_initialize :user

  FORUMS_QUERY = 'forum_id in (:user_forums)'
  MY_CLUBS_QUERY = "(
    type = #{Entry.sanitize ClubComment.name} and
    #{Entry.table_name}.linked_id in (:user_clubs)
  )"

  def initialize user
    @user = user
    @relation = prepare_query

    @relation = except_hentai @relation
  end

  def by_forum forum
    case forum && forum.permalink
      when nil
        if @user
          user_forums
        else
          where_not type: ClubComment.name
        end

      when 'reviews'
        where forum_id: forum.id
        order! created_at: :desc

      when Forum::NEWS_FORUM.permalink
        where type: [SiteNews.name, AnimeNews.name, MangaNews.name, CosplayComment.name]
        where generated: false
        order! created_at: :desc

      when Forum::UPDATES_FORUM.permalink
        where type: [AnimeNews.name, MangaNews.name]
        where generated: true
        order! created_at: :desc

      when Forum::MY_CLUBS_FORUM.permalink
        where MY_CLUBS_QUERY, user_clubs: @user.club_roles.pluck(:club_id)

      else
        where forum_id: forum.id
    end

    except_generated forum

    self
  end

  def by_linked linked
    return self unless linked
    where linked: linked
    self
  end

  def as_views is_preview, is_mini
    result.map do |topic|
      Topics::Factory.new(is_preview, is_mini).build topic
    end
  end

private

  def prepare_query
    Entry
      .with_viewed(@user)
      .includes(:forum, :user)
      .order_default
  end

  def except_generated forum
    @relation = if forum == Forum::NEWS_FORUM || forum == Forum::UPDATES_FORUM
      @relation.wo_episodes
    else
      @relation.wo_empty_generated
    end
  end

  def except_hentai query
    query
      .joins("left join animes on animes.id=linked_id and linked_type='Anime'")
      .where('animes.id is null or animes.censored=false')
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
end
