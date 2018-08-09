class Topics::Query < QueryObjectBase
  FORUMS_QUERY = 'forum_id in (:user_forums)'
  MY_CLUBS_QUERY = <<-SQL.squish
    (
      type in (
        #{ApplicationRecord.sanitize Topics::EntryTopics::ClubTopic.name},
        #{ApplicationRecord.sanitize Topics::ClubUserTopic.name}
      ) and #{Topic.table_name}.linked_id in (:user_club_ids)
    ) or
    (
      type =
        #{ApplicationRecord.sanitize Topics::EntryTopics::ClubPageTopic.name}
        and #{Topic.table_name}.linked_id in (:user_club_page_ids)
    )
  SQL
  NEWS_QUERY = <<-SQL.squish
    (
      type = '#{Topics::NewsTopic.name}' and
      generated = false
    ) or (
      type in (
        '#{Topics::EntryTopics::CosplayGalleryTopic.name}',
        '#{Topics::NewsTopics::ContestStatusTopic.name}'
      ) and
      generated = true
    )
  SQL
  CLUBS_JOIN = <<-SQL.squish
    left join clubs as clubs_1 on
      clubs_1.id = linked_id and linked_type = '#{Club.name}'

    left join club_pages on
      club_pages.id = linked_id and linked_type = '#{ClubPage.name}'

    left join clubs as clubs_2 on
      club_pages.club_id = clubs_2.id
  SQL
  CLUBS_WHERE = <<-SQL.squish
    (linked_type = '#{Club.name}' and linked_id in (:user_club_ids)) or
    (linked_type = '#{ClubPage.name}' and linked_id in (:user_club_page_ids)) or
      clubs_1.is_censored = false or
      clubs_2.is_censored = false
  SQL
  BY_LINKED_CLUB_SQL = <<-SQL.squish
    (
      (linked_id = :club_id and linked_type = '#{Club.name}') or
      (linked_id in (:club_page_ids) and linked_type = '#{ClubPage.name}')
    ) and (
      type not in (
        '#{Topics::EntryTopics::ClubTopic.name}',
        '#{Topics::EntryTopics::ClubPageTopic.name}'
      ) or comments_count != 0
    )
  SQL

  def self.fetch _user, locale
    query = new Topic
      .includes(:forum, :user)
      .order(updated_at: :desc)
      .where(locale: locale)

    query.except_hentai#.except_ignored(user)
  end

  def by_forum forum, user, is_censored_forbidden
    new_scope = except_episodes(@scope, forum)
    chain forum_scope(new_scope, forum, user, is_censored_forbidden)
  end

  def by_linked linked
    if linked.is_a? Club
      chain @scope.where(BY_LINKED_CLUB_SQL,
        club_id: linked.id,
        club_page_ids: linked.pages.pluck(:id)
      )
    elsif linked
      chain @scope.where(linked: linked)
    else
      self
    end
  end

  # def except_ignored user
    # if user
      # chain @scope.where.not id: user.topic_ignores.map(&:topic_id)
    # else
      # self
    # end
  # end

  def search phrase, forum, user, locale
    chain Topics::SearchQuery.call(
      scope: @scope,
      phrase: phrase,
      forum: forum,
      user: user,
      locale: locale
    )
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
          scope.where('type not in (?) OR type IS NULL', [
            Topics::EntryTopics::ClubTopic.name,
            Topics::ClubUserTopic.name,
            Topics::EntryTopics::ClubPageTopic.name
          ])
        end

      when 'reviews'
        scope
          .where(forum_id: forum.id)
          .except(:order)
          .order(created_at: :desc)

      when 'clubs'
        new_scope = scope
          .where(forum_id: forum.id)
          .where(linked_type: [Club.name, ClubPage.name])

        if is_censored_forbidden
          new_scope
            .joins(CLUBS_JOIN)
            .where(CLUBS_WHERE,
              user_club_ids: user_club_ids(user),
              user_club_page_ids: user_club_page_ids(user)
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
            user_club_ids: user_club_ids(user),
            user_club_page_ids: user_club_page_ids(user)
          )

      else
        scope
          .where(forum_id: forum.id)
    end
  end

  def user_forums scope, user
    if user.preferences.forums.include? Forum::MY_CLUBS_FORUM.permalink
      scope.where("#{FORUMS_QUERY} or #{MY_CLUBS_QUERY}",
        user_forums: user.preferences.forums.map(&:to_i),
        user_club_ids: user_club_ids(user),
        user_club_page_ids: user_club_page_ids(user)
      )
    else
      scope.where(FORUMS_QUERY, user_forums: user.preferences.forums.map(&:to_i))
    end
  end

  def user_club_ids user
    return [] unless user

    @user_club_ids ||= {}
    @user_club_ids[user.id] ||= user.club_roles.pluck(:club_id)
  end

  def user_club_page_ids user
    return [] unless user

    ClubPage.where(club_id: user_club_ids(user)).pluck(:id)
  end
end
