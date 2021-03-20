class Notifications::BroadcastTopic
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args.first },
    queue: :history_jobs
  )

  NEWS_EXPIRE_IN = 1.week
  MESSAGES_PER_JOB = 1000
  MESSAGE_ATTRIBUTES = %w[from_id kind linked_id linked_type created_at]

  def perform topic_id
    topic = Topic.find_by id: topic_id
    return if !topic || topic.processed?

    if skip? topic
      topic.update_column :processed, true
      return
    end

    message_attributes = prepare_message topic
    user_ids = subscribed_user_ids topic

    schedule_send message_attributes, user_ids
    topic.update_column :processed, true
  end

private

  def schedule_send message, user_ids
    user_ids.each_slice(MESSAGES_PER_JOB) do |slice|
      Notifications::SendMessages.perform_async message, slice
    end
  end

  def skip? topic
    return false if topic.broadcast?

    !topic.is_a?(Topics::NewsTopic) ||
      expired?(topic) ||
      music?(topic) ||
      censored?(topic)
  end

  def music? topic
    topic.linked.respond_to?(:kind_music?) && topic.linked&.kind_music?
  end

  def censored? topic
    topic.linked.respond_to?(:censored?) && topic.linked&.censored?
  end

  def expired? topic
    (topic.created_at || Time.zone.now) < NEWS_EXPIRE_IN.ago
  end

  def contest? topic
    topic.is_a? Topics::NewsTopics::ContestStatusTopic
  end

  def subscribed_user_ids topic
    Topics::SubscribedUsersQuery.call(topic).pluck :id
  end

  def prepare_message topic
    Message
      .new(
        from: topic.user,
        kind: message_type(topic),
        linked: linked(topic),
        # `usec` is used to fix unstable specs in CIRCLE_CI
        created_at: topic.created_at.change(usec: 0)
      )
      .attributes
      .slice(*MESSAGE_ATTRIBUTES)
  end

  def message_type topic
    if topic.broadcast?
      MessageType::SITE_NEWS
    elsif contest? topic
      'Contest' + topic.action.camelize
    else
      topic.action ||
        raise(ArgumentError, topic.action || topic.action.to_json)
    end
  end

  def linked topic
    if contest? topic
      topic.linked
    else
      topic
    end
  end
end
