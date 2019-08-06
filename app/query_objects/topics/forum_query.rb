class Topics::ForumQuery
  method_object %i[scope forum user is_censored_forbidden]

  FORUMS_QUERY = 'forum_id in (:user_forums)'
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

  def call
    case @forum && @forum.permalink
      when nil
        if @user
          user_forums
        else
          @scope.where(
            'type not in (?) OR type IS NULL', [
              Topics::EntryTopics::ClubTopic.name,
              Topics::ClubUserTopic.name,
              Topics::EntryTopics::ClubPageTopic.name
            ]
          )
        end

      when 'reviews'
        @scope
          .where(forum_id: @forum.id)
          .except(:order)
          .order(created_at: :desc)

      when 'clubs'
        new_scope = @scope
          .where(forum_id: @forum.id)
          .where(linked_type: [Club.name, ClubPage.name])

        if @is_censored_forbidden
          new_scope
            .joins(CLUBS_JOIN)
            .where(
              CLUBS_WHERE,
              user_club_ids: user_club_ids,
              user_club_page_ids: user_club_page_ids
            )
        else
          new_scope
        end

      when Forum::NEWS_FORUM.permalink
        @scope
          .where(NEWS_QUERY)
          .except(:order)
          .order(created_at: :desc)

      when Forum::UPDATES_FORUM.permalink
        @scope
          .where(type: [Topics::NewsTopic.name], generated: true)
          .except(:order)
          .order(created_at: :desc)

      when Forum::MY_CLUBS_FORUM.permalink
        @scope
          .where(
            MY_CLUBS_QUERY,
            user_club_ids: user_club_ids,
            user_club_page_ids: user_club_page_ids
          )

      else
        @scope
          .where(forum_id: @forum.id)
    end
  end

private

  def user_forums
    if @user.preferences.forums.include? Forum::MY_CLUBS_FORUM.permalink
      @scope
        .where(
          "#{FORUMS_QUERY} or #{MY_CLUBS_QUERY}",
          user_forums: @user.preferences.forums.map(&:to_i),
          user_club_ids: user_club_ids,
          user_club_page_ids: user_club_page_ids
        )
    else
      @scope
        .where(FORUMS_QUERY, user_forums: @user.preferences.forums.map(&:to_i))
    end
  end

  def user_club_ids
    @user_club_ids ||= @user&.club_roles&.pluck(:club_id) || []
  end

  def user_club_page_ids
    @user_club_page_ids ||= ClubPage.where(club_id: user_club_ids).pluck(:id)
  end
end
