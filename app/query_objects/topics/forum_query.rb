class Topics::ForumQuery # rubocop:disable ClassLength
  method_object %i[
    scope
    forum
    user
    is_censored_forbidden
  ]

  FORUMS_QUERY = 'forum_id in (:user_forums)'
  NEWS_QUERY = <<-SQL.squish
    (
      #{Topic.table_name}.type = '#{Topics::NewsTopic.name}' and
      forum_id = #{Forum::NEWS_ID} and
      generated = false
    ) or (
      #{Topic.table_name}.type in (
        '#{Topics::EntryTopics::CosplayGalleryTopic.name}',
        '#{Topics::NewsTopics::ContestStatusTopic.name}'
      ) and
      generated = true
    )
  SQL
  CLUBS_QUERY = <<-SQL.squish
    (
      #{Topic.table_name}.type in (
        #{ApplicationRecord.sanitize Topics::EntryTopics::ClubTopic.name},
        #{ApplicationRecord.sanitize Topics::ClubUserTopic.name}
      ) and #{Topic.table_name}.linked_id in (:club_ids)
    ) or (
      #{Topic.table_name}.type =
        #{ApplicationRecord.sanitize Topics::EntryTopics::ClubPageTopic.name}
        and #{Topic.table_name}.linked_id in (:club_page_ids)
    )
  SQL

  FORUM_WITH_TAG_QUERY = <<-SQL.squish
    forum_id = %<forum_id>i or (
      forum_id = #{Forum::NEWS_ID} and (%<tags>s)
  )
  SQL

  def call
    scope = scope_by_forum
    scope.where! is_censored: false if @is_censored_forbidden
    scope
  end

private

  def scope_by_forum # rubocop:disable all
    case @forum&.permalink
      when nil
        if @user
          user_forums
        else
          guest_forums
        end

      when 'critiques'
        critiques_forums

      when 'clubs'
        clubs_forums

      when 'news'
        news_forums

      when Forum::UPDATES_FORUM.permalink
        updates_forums

      when Forum::MY_CLUBS_FORUM.permalink
        my_clubs_forums

      when 'animanga'
        @scope.where(
          format(FORUM_WITH_TAG_QUERY, forum_id: @forum.id, tags: tags_sql(%w[аниме манга ранобэ]))
        )

      when 'site'
        @scope.where(
          format(FORUM_WITH_TAG_QUERY, forum_id: @forum.id, tags: tags_sql(%w[сайт]))
        )

      when 'games'
        @scope.where(
          format(FORUM_WITH_TAG_QUERY, forum_id: @forum.id, tags: tags_sql(%w[игры]))
        )

      when 'vn'
        @scope.where(
          format(FORUM_WITH_TAG_QUERY, forum_id: @forum.id, tags: tags_sql(%w[визуальные_новеллы]))
        )

      else
        @scope
          .where(forum_id: @forum.id)
    end
  end

  def user_forums
    if @user.preferences.forums.include? Forum::MY_CLUBS_FORUM.permalink
      @scope
        .where(
          "#{FORUMS_QUERY} or #{CLUBS_QUERY}",
          user_forums: @user.preferences.forums.map(&:to_i),
          club_ids: user_club_ids,
          club_page_ids: user_club_page_ids
        )
    else
      @scope
        .where(FORUMS_QUERY, user_forums: @user.preferences.forums.map(&:to_i))
    end
  end

  def guest_forums
    @scope
      .where(
        "#{Topic.table_name}.type not in (?) OR #{Topic.table_name}.type IS NULL", [
          Topics::EntryTopics::ClubTopic.name,
          Topics::ClubUserTopic.name,
          Topics::EntryTopics::ClubPageTopic.name
        ]
      )
      .where.not(forum_id: Forum::HIDDEN_ID)
  end

  def critiques_forums
    @scope
      .where(forum_id: @forum.id)
      .except(:order)
      .order(created_at: :desc)
  end

  def clubs_forums
    @scope
      .where(forum_id: @forum.id)
      .where(linked_type: [Club.name, ClubPage.name])
  end

  def news_forums
    @scope
      .where(NEWS_QUERY)
      .except(:order)
      .order(created_at: :desc)
  end

  def updates_forums
    @scope
      .where(type: [Topics::NewsTopic.name], generated: true)
      .except(:order)
      .order(created_at: :desc)
  end

  def my_clubs_forums
    @scope.where(
      CLUBS_QUERY,
      club_ids: user_club_ids,
      club_page_ids: user_club_page_ids
    )
  end

  def user_club_ids
    @user_club_ids ||= @user&.club_roles&.pluck(:club_id) || []
  end

  def user_club_page_ids
    @user_club_page_ids ||= ClubPage.where(club_id: user_club_ids).pluck(:id)
  end

  def tags_sql tags
    tags
      .map { |tag| "tags @> '{#{tag}}'" }
      .join(' or ')
  end
end
