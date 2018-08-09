class Topics::HotTopicsQuery < ServiceObjectBase
  SELECT_SQL = <<-SQL
    commentable_id,
    max(commentable_type) as commentable_type,
    count(*) as comments_count
  SQL
  JOIN_SQL = <<-SQL
    inner join topics on
      topics.id = commentable_id
      and topics.type not in (
        '#{Topics::EntryTopics::ClubTopic.name}',
        '#{Topics::ClubUserTopic.name}',
        '#{Topics::EntryTopics::ClubPageTopic.name}'
      )
  SQL

  INTERVAL = Rails.env.development? ? 1.month : 1.day
  LIMIT = 8

  pattr_initialize :locale

  def call
    topic_comments
      .limit(LIMIT)
      .map(&:commentable)
  end

private

  def topic_comments
    Comment
      .where(commentable_type: Topic.name)
      .where('comments.created_at > ?', INTERVAL.ago)
      .where(topics: { locale: @locale })
      .where.not(topics: { id: offtopic_id })
      .joins(JOIN_SQL)
      .group(:commentable_id)
      .select(SELECT_SQL)
      .order(comments_count: :desc)
  end

  def offtopic_id
    Topic::TOPIC_IDS[:offtopic][@locale.to_sym]
  end
end
