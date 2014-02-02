class AnimeHistoryService
  include Rails.application.routes.url_helpers
  NewsExpireIn = 1.week
  default_url_options[:host] = 'shikimori.org'

  # обрабатывает всю небработанную историю, отправляет уведомления пользователям
  def self.process
    entries = Entry
      .where("processed = false or processed is null")
      .where("(type = ? and generated = true) or broadcast = true", AnimeNews.name)
      .order(:created_at)
      .to_a
    return if entries.empty?

    users = User
      .includes(anime_rates: [:anime])
      .references(:user_rates)
      .where("user_rates.id is null or (user_rates.target_type = ? and user_rates.target_id in (?))",
              Anime.name, entries.map(&:linked_id))
      .to_a

    users += User
      .where.not(id: users.map(&:id))
      .each {|v| v.association(:anime_rates).loaded! }
      .uniq(&:id)

    # алоритм очень не оптимальный. позже, когда начнет сильно тормозить, нужно будет переделать
    messages = entries.map do |entry|
      # новости о уже не существующих элементах, или о зацензуренных элементах, или о музыке не создаём
      next if entry.class == AnimeNews && (!entry.linked || entry.linked.censored || entry.linked.kind == 'Music')
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
      Message.import messages.flatten.compact
    end
  end

  def new_episode_topic_subject(anime, history)
    "%s эпизод %s" % [history.value, anime.name]
  end

  def new_episode_topic_text(anime, history)
    part = history.value.to_i == anime.episodes ?
        'последний' :
        (anime.episodes > 0 ? "#{history.value} из #{anime.episodes}" : history.value)
    "Вышел #{part} эпизод [anime=#{anime.id}]#{anime.name}[/anime]."
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
    "#{part} аниме [anime=#{anime.id}]#{anime.name}[/anime]. #{history.to_s(:full)}."
  end

  def new_ongoing_topic_subject(anime, history)
    "%s %s" % [history.to_s(:short), anime.name]
  end
  def new_ongoing_topic_text(anime, history)
    part1 = [
      "[anime=#{anime.id}]#{anime.name}[/anime] стало онгоингом",
      "Начат показ [anime=#{anime.id}]#{anime.name}[/anime]",
      "[anime=#{anime.id}]#{anime.name}[/anime] теперь онгоинг"
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
    #score_text = case (["TV", "Movie"].include?(anime.kind) ? anime.score : anime.score-0.5)
      #when 9.0..10.0
        #"Шедевр! Всем смотреть!"
      #when 8.5..9.0
        #"Пожалуй, лучшее аниме сезона. Смотреть обязательно!"
      #when 7.9..8.5
        #"Очень, очень хорошо, это стоит посмотреть."
      #when 7.5..7.9
        #"Неплохо, советую посмотреть."
      #when 7.1..7.5
        #"Можно будет посмотреть, но скорее всего не очень."
      #when 6.6..7.1
        #"Как-то слабовато, но возможно стоит посмотреть."
      #when 6.0..6.6
        #"Совсем плохо, смотреть не стоит."
      #when 0.0..6.0
        #"Полный провал, даже не тратьте своё время."
    #end
    part = [
      "Зарелизилось",
      "Вышло",
      "Зарелизилось аниме",
      "Закончилось аниме",
      "Вышло аниме"
    ].sample
    text = "#{part} [anime=#{anime.id}]#{anime.name}[/anime]"
    text += if anime.score != 0 && anime.score < 9.9
       ", средняя оценка пользователей #{anime.score}."
    else
      '.'
    end
    text
  end
end
