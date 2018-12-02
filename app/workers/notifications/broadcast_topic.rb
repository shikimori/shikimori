class Notifications::BroadcastTopic
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args.first },
    queue: :history_jobs
  )

  NEWS_EXPIRE_IN = 1.week

  def perform topic_id
    topic = Topic.find_by id: topic_id
    return [] if !topic || topic.processed?

    if skip? topic
      topic.update_column :processed, true
      return []
    end

    messages = build_messages topic

    ApplicationRecord.transaction do
      topic.update_column :processed, true
      messages.each_slice(5000) { |slice| Message.import slice, validate: false }
    end

    messages
  end

private

  def skip? topic
    return false if topic.broadcast?

    !topic.is_a?(Topics::NewsTopic) ||
      expired?(topic) ||
      music?(topic) ||
      censored?(topic)
  end

  def music? topic
    topic.linked&.respond_to?(:kind_music?) && topic.linked&.kind_music?
  end

  def censored? topic
    topic.linked&.respond_to?(:censored?) && topic.linked&.censored?
  end

  def expired? topic
    (topic.created_at || Time.zone.now) < NEWS_EXPIRE_IN.ago
  end

  def build_messages topic
    subscribed_users(topic).map do |user|
      build_message topic, user
    end
  end

  def subscribed_users topic
    Topics::SubscribedUsersQuery.call topic
  end

  def build_message topic, user
    Message.new(
      from: topic.user,
      to: user,
      body: nil,
      kind: message_type(topic),
      linked: topic,
      created_at: topic.created_at
    )
  end

  def message_type topic
    if topic.broadcast?
      MessageType::SiteNews
    else
      topic.action || raise(ArgumentError, topic.action || topic.action.to_json)
    end
  end
end

