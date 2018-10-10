class Notifications::BroadcastTopic
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args.first },
    queue: :history_jobs
  )

  NEWS_EXPIRE_IN = 1.week

  def perform topic
    return topic.update_column :processed, true if ignored?(topic) || expired?(topic)

    messages = build_messages topic

    ApplicationRecord.transaction do
      topic.update_column :processed, true
      messages.each_slice(5000) { |slice| Message.import slice, validate: false }
    end
  end

private

  def ignored? topic
    topic.is_a?(Topics::NewsTopic) &&
      (!topic.linked || topic.linked.censored? || topic.linked.kind_music?)
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
    if topic.class == Topics::NewsTopic && topic.broadcast
      MessageType::SiteNews
    else
      topic.action || raise("unknown message_type for topic #{topic.id}")
    end
  end
end
