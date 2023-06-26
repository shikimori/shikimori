class Topics::HotTopicsQuery
  method_object %i[limit]

  SELECT_SQL = <<-SQL.squish
    commentable_id,
    max(commentable_type) as commentable_type,
    count(*) as comments_count
  SQL
  JOIN_SQL = <<-SQL.squish
    inner join topics on
      topics.id = commentable_id
      and topics.type not in (
        '#{Topics::EntryTopics::ClubTopic.name}',
        '#{Topics::ClubUserTopic.name}',
        '#{Topics::EntryTopics::ClubPageTopic.name}'
      )
  SQL

  INTERVAL = Rails.env.development? ? 1.month : 1.day

  def call
    topic_comments
      .limit(@limit)
      .includes(:topic)
      .map(&:commentable)
      .reject do |topic|
        # for collection topics track only published collections
        topic.is_a?(Topics::EntryTopics::CollectionTopic) &&
          !topic.linked.published?
      end
  end

private

  def topic_comments
    Comment
      .where(commentable_type: Topic.name)
      .where('comments.created_at > ?', INTERVAL.ago)
      .where.not(topics: { id: offtopic_id })
      .joins(JOIN_SQL)
      .group(:commentable_id)
      .select(SELECT_SQL)
      .order(Arel.sql('comments_count desc'))
  end

  def offtopic_id
    Topic::TOPIC_IDS[:offtopic]
  end
end
