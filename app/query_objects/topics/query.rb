class Topics::Query < QueryObjectBase
  BY_LINKED_CLUB_SQL = <<-SQL.squish
    (
      (linked_id = :club_id and linked_type = '#{Club.name}') or
      (linked_id in (:club_page_ids) and linked_type = '#{ClubPage.name}')
    ) and (
      topics.type not in (
        '#{Topics::EntryTopics::ClubTopic.name}',
        '#{Topics::EntryTopics::ClubPageTopic.name}'
      ) or comments_count != 0
    )
  SQL

  def self.fetch locale, is_censored_forbidden
    query = new Topic
      .includes(:forum, :user, :linked)
      .order(updated_at: :desc)
      .where(locale: locale)

    # .except_ignored(user)
    if is_censored_forbidden
      Topics::ExceptHentaiQuery.call query
    else
      query
    end
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
          BY_LINKED_CLUB_SQL,
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

  def as_views is_preview, is_mini
    mapped_scope = MappedCollection.new @scope do |topic|
      Topics::TopicViewFactory.new(is_preview, is_mini).build topic
    end

    chain mapped_scope
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
