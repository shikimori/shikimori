class HistoryWorker
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :cpu_intensive
  )

  NEWS_EXPIRE_IN = 1.week

  prepend ActiveCacher.instance
  instance_cache :users, :topics

  def perform
    RedisMutex.with_lock('history_worker', block: 0) do
      topics.each { |topic| process_topic topic }
    end
  rescue RedisMutex::LockError
  end

private

  def process_topic topic
    return if ignored? topic
    # протухшие новости тоже не нужны
    return if expired? topic

    messages = build_messages topic

    ActiveRecord::Base.transaction do
      topic.update_column :processed, true
      messages.each_slice(1000) { |slice| Message.import slice, validate: false }
    end
    messages.each { |message| message.send :send_push_notifications }
  end

  def build_messages topic
    users
      .select { |v| v.subscribed_for_event? topic }
      .map { |user| build_message topic, user }
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

  def topics
    Entry
      .includes(:user)
      .where.not(processed: true)
      .where('(type = ? and generated = true) or broadcast = true', Topics::NewsTopic.name)
      .order(:created_at)
      .to_a
  end

  def users
    users_with_anime = User
      .includes(:devices, anime_rates: [:anime])
      .references(:user_rates)#.where(id: 1..1000)
      .where('user_rates.id is null or (user_rates.target_type = ? and user_rates.target_id in (?))',
              Anime.name, topics.map(&:linked_id))
      .to_a

    users_without_anime = User
      .includes(:devices)
      .where.not(id: users_with_anime.map(&:id))#.where(id: 1..1000)
      .each { |v| v.association(:anime_rates).loaded! }
      .uniq(&:id)

    users_with_anime + users_without_anime
  end

  def message_type topic
    if topic.class == Topics::NewsTopic && topic.broadcast
      MessageType::SiteNews
    else
      topic.action || fail("unknown message_type for topic #{topic.id}")
    end
  end

  def ignored? topic
    topic.class == Topics::NewsTopic &&
      (!topic.linked || topic.linked.censored || topic.linked.kind_music?) &&
      !topic.broadcast
  end

  def expired? topic
    (topic.created_at || Time.zone.now) + NEWS_EXPIRE_IN < Time.zone.now
  end
end
