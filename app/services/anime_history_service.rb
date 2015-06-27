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
      .includes(anime_rates: [:anime])
      .references(:user_rates)#.where(id: 1)
      .where('user_rates.id is null or (user_rates.target_type = ? and user_rates.target_id in (?))',
              Anime.name, entries.map(&:linked_id))
      .to_a

    users += User
      .where.not(id: users.map(&:id))#.where(id: 1)
      .each {|v| v.association(:anime_rates).loaded! }
      .uniq(&:id)

    #users = users.select {|v| [1].include? v.id }

    # алоритм очень не оптимальный. позже, когда начнет сильно тормозить, нужно будет переделать
    messages = entries.map do |entry|
      # новости о уже не существующих элементах, или о зацензуренных элементах, или о музыке не создаём
      next if entry.class == AnimeNews && (!entry.linked || entry.linked.censored || entry.linked.music?)
      # протухшие новости тоже не нужны
      next if entry.created_at + NewsExpireIn < DateTime.now

      users
        .select {|v| v.subscribed_for_event? entry }
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

    ActiveRecord::Base.transaction do
      Entry.where(id: entries.map(&:id)).update_all processed: true

      messages.flatten.compact.each_slice 1000 do |slice|
        Message.import slice
      end
    end
  end

  def new_episode_topic_subject(anime, history)
    "%s эпизод %s" % [history.value, anime.name]
  end

  def new_episode_topic_text(anime, history)
    part = history.value.to_i == anime.episodes ?
        'последний' :
        (anime.episodes > 0 ? "#{history.value} из #{anime.episodes}" : history.value)
    "Вышел #{part} эпизод [anime=#{anime.id}]#{filter_name anime.name}[/anime]."
  end

  def new_anons_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end
  def new_anons_topic_text(anime, history)
    part = [
      "Состоялся анонс",
      "Было анонсировано",
      "Анонсированно",
      "Объявлено о выпуске",
      "Появилась информация об",
      "Запланировано создание"
    ].sample
    "#{part} аниме [anime=#{anime.id}]#{filter_name anime.name}[/anime]. #{history.to_s(:full)}."
  end

  def new_ongoing_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end
  def new_ongoing_topic_text(anime, history)
    part1 = [
      "[anime=#{anime.id}]#{filter_name anime.name}[/anime] стало онгоингом",
      "Начат показ [anime=#{anime.id}]#{filter_name anime.name}[/anime]",
      "[anime=#{anime.id}]#{filter_name anime.name}[/anime] теперь онгоинг"
    ]
    part2 = [
      "первый эпизод скоро появится на торрентах",
      "первый эпизод скоро появится в сети",
      "первый эпизод вскоре появится на торрентах",
      "первый эпизод вскоре появится в сети",
      "вскоре появится первый эпизод",
      "скоро будет доступен первый эпизод",
      "скоро появится первый эпизод"
    ]
    "%s, %s." % [part1.sample, part2.sample]
  end

  def new_release_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end
  def new_release_topic_text(anime, history)
    anime_url = url_for(anime).sub('http://', '')
    part = [
      "Зарелизилось",
      "Вышло",
      "Зарелизилось аниме",
      "Закончилось аниме",
      "Вышло аниме"
    ].sample
    text = "#{part} [anime=#{anime.id}]#{filter_name anime.name}[/anime]"
    text += if anime.score != 0 && anime.score < 9.9
       ", средняя оценка пользователей #{anime.score}."
    else
      '.'
    end
    text
  end

  def filter_name name
    name.gsub('[', ' ').gsub(']', ' ').gsub('  ', ' ')
  end
end
