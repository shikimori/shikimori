class Topics::HotTopicsQuery < ServiceObjectBase
  SELECT_SQL = <<-SQL
    commentable_id,
    max(commentable_type) as commentable_type,
    count(*) as comments_count
  SQL
  JOIN_SQL = <<-SQL
    inner join topics on
      topics.id = commentable_id
      and topics.type != '#{Topics::EntryTopics::ClubTopic.name}'
  SQL

  INTERVAL = Rails.env.development? ? 1.month : 1.day
  LIMIT = 8

  def call
    Comment
      .where(commentable_type: Topic.name)
      .where('comments.created_at > ?', INTERVAL.ago)
      .joins(JOIN_SQL)
      .group(:commentable_id)
      .select(SELECT_SQL)
      .order('comments_count desc')
      .limit(LIMIT)
      .map(&:commentable)
  end
end
