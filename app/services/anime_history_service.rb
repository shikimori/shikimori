class AnimeHistoryService
  include Routing
  NewsExpireIn = 1.week

  # обрабатывает всю небработанную историю, отправляет уведомления пользователям
  def self.process
    entries = Entry
      .where.not(processed: true)
      .where('(type = ? and generated = true) or broadcast = true', AnimeNews.name)
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
    messages = entries.flat_map do |entry|
      # новости о уже не существующих элементах, или о зацензуренных элементах, или о музыке не создаём
      next if entry.class == AnimeNews && (!entry.linked || entry.linked.censored || entry.linked.kind_music?)
      # протухшие новости тоже не нужны
      next if entry.created_at + NewsExpireIn < DateTime.now

      users
        .select { |v| v.subscribed_for_event? entry }
        .map do |user|
          Message.new(
            from_id: entry.user_id,
            to_id: user.id,
            body: nil,
            kind: entry.action,
            linked: entry,
            created_at: entry.created_at
          )
        end
    end
    messages.compact!

    ActiveRecord::Base.transaction do
      Entry.where(id: entries.map(&:id)).update_all processed: true
      messages.each_slice 1000 { |slice| Message.import slice }
    end

    messages.each { |message| message.send :send_push_notifications }
  end

  # TODO localize this later
  def new_episode_topic_subject(anime, history)
    "%s эпизод %s" % [history.value, anime.name]
  end

  def new_anons_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end

  def new_ongoing_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end

  def new_release_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end

  def filter_name name
    name.gsub('[', ' ').gsub(']', ' ').gsub('  ', ' ')
  end
end
