class AnimeHistoryService
  include Routing
  NewsExpireIn = 1.week

  # обрабатывает всю небработанную историю, отправляет уведомления пользователям
  def self.process
    entries = Entry
      .where.not(processed: true)
      .where('(type = ? and generated = true) or broadcast = true', Topics::NewsTopic.name)
      .order(:created_at)
      .to_a
    return if entries.empty?

    users = User
      .includes(:devices, anime_rates: [:anime])
      .references(:user_rates)#.where(id: 1)
      .where('user_rates.id is null or (user_rates.target_type = ? and user_rates.target_id in (?))',
              Anime.name, entries.map(&:linked_id))
      .to_a

    users += User
      .includes(:devices)
      .where.not(id: users.map(&:id))#.where(id: 1)
      .each { |v| v.association(:anime_rates).loaded! }
      .uniq(&:id)

    #users = users.select {|v| [1].include? v.id }

    # алоритм очень не оптимальный. позже, когда начнет сильно тормозить, нужно будет переделать
    entries.each do |entry|
      # новости о уже не существующих элементах, или о зацензуренных элементах, или о музыке не создаём
      next if entry.class == Topics::NewsTopic &&
        (!entry.linked || entry.linked.censored || entry.linked.kind_music?) &&
        !entry.broadcast
      # протухшие новости тоже не нужны
      next if (entry.created_at || Time.zone.now) + NewsExpireIn < Time.zone.now

      messages = users
        .select { |v| v.subscribed_for_event? entry }
        .map do |user|
          Message.new(
            from_id: entry.user_id,
            to_id: user.id,
            body: nil,
            kind: message_type(entry),
            linked: entry,
            created_at: entry.created_at
          )
        end

      ActiveRecord::Base.transaction do
        entry.update processed: true
        messages.each_slice(1000) { |slice| Message.import slice }
      end
      messages.each { |message| message.send :send_push_notifications }
    end
  end

  def self.message_type topic
    if topic.class == Topics::NewsTopic && topic.broadcast
      MessageType::SiteNews
    else
      topic.action || fail("unknown message_type for topic #{topic.id}")
    end
  end
end
