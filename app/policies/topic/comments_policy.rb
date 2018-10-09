# frozen_string_literal: true

class Topic::CommentsPolicy
  prepend ActiveCacher.instance
  instance_cache :summaries_count

  pattr_initialize :topic

  def comments_count
    topic.comments_count
  end

  def summaries_count
    topic.comments.summaries.count
  end

  def any_comments?
    topic.comments_count.positive?
  end

  def any_summaries?
    summaries_count.positive?
  end

  def all_summaries?
    summaries_count == topic.comments_count
  end
end
