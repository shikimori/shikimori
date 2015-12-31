class AnimeNews < DbEntryThread
  enumerize :action, in: [:anons, :ongoing, :released, :episode], predicates: true

  attr_defaults forum_id: -> { FORUM_IDS[Anime.name] }
  attr_defaults title: -> { generate_title linked }
  attr_defaults text: -> { 'text' }

  # получение названия для новости
  def generate_title anime
    service = AnimeHistoryService.new

    case action
      when AnimeHistoryAction::Episode
        service.new_episode_topic_subject(anime, self)

      when AnimeHistoryAction::Anons
        service.new_anons_topic_subject(anime, self)

      when AnimeHistoryAction::Released
        service.new_release_topic_subject(anime, self)

      when AnimeHistoryAction::Ongoing
        service.new_ongoing_topic_subject(anime, self)
    end
  end

  # создание новости о новом эпизоде
  def self.create_for_new_episode(anime, pubDate)
    AnimeNews.find_by(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Episode,
      value: anime.episodes_aired.to_s,
    ) || AnimeNews.create!(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Episode,
      value: anime.episodes_aired.to_s,
      created_at: pubDate,
      generated: true
    )
  end

  # создание новости о новом анонсе
  def self.create_for_new_anons(anime)
    AnimeNews.find_or_create_by!(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Anons,
      generated: true
    )
  end

  # создание новости о новом онгоинге
  def self.create_for_new_ongoing(anime)
    AnimeNews.find_or_create_by!(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Ongoing,
      generated: true
    )
  end

  # создание новости о новом релизе
  def self.create_for_new_release(anime)
    old_release = (anime.released_on && anime.released_on + 2.weeks < Time.zone.now)# ||
                  #(anime.released_on == nil && anime.aired_on && anime.aired_on + 2.weeks < Time.zone.now)

    entry = AnimeNews.find_by(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Released
    ) || AnimeNews.create!(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Released,
      generated: true,
      processed: old_release,
      created_at: old_release ? anime.released_on : Time.zone.now
    )

    anime.released_on = entry.created_at
    entry
  end

  def to_s(type=:short)
    case self.action
      when AnimeHistoryAction::Episode
        "Вышел #{self.value} эпизод"

      when AnimeHistoryAction::Anons
        #if type == :normal
          #if self.anime.aired_on
            #if self.anime.aired_on.day == 1 && self.anime.aired_on.month == 1
              #"Анонсировано на %d год" % self.anime.aired_on.year
            #else
              #"Анонсировано на %s года" % Russian::strftime(self.anime.aired_on, "%d %B %Y").sub(/\b0(\d)\b/, '\1')
            #end
          #else
            #"Анонсировано, пока без даты"
          #end

        #elsif type == :full
          #if self.anime.aired_on
            #if self.anime.aired_on.day == 1 && self.anime.aired_on.month == 1
              #"Выход запланирован на %d год" % [self.anime.aired_on.year]
            #else
              #"Дата выхода объявлена на %s года" % [Russian::strftime(self.anime.aired_on, "%d %B %Y").sub(/\b0(\d)\b/, '\1')]
            #end
          #else
            #"Дата выхода пока не объявлена"
          #end

        #else
          "Анонсировано аниме"
        #end

      when AnimeHistoryAction::Ongoing
        "Начало показа аниме"

      when AnimeHistoryAction::Released
        "Завершение показа аниме"

      else
        title
    end
  end
end
