class AnimeNews < AniMangaEntry
  attr_defaults section_id: -> { SectionIDs[Anime.name] }
  attr_defaults title: -> { generate_title linked }
  attr_defaults text: -> { generate_text linked }

  # получение названия для новости
  def generate_title(anime)
    service = AnimeHistoryService.new

    case action
      when AnimeHistoryAction::Episode
        service.new_episode_topic_subject(anime, self)

      when AnimeHistoryAction::Anons
        service.new_anons_topic_subject(anime, self)

      when AnimeHistoryAction::Release
        service.new_release_topic_subject(anime, self)

      when AnimeHistoryAction::Ongoing
        service.new_ongoing_topic_subject(anime, self)
    end
  end

  # получение текста для новости
  def generate_text(anime)
    service = AnimeHistoryService.new

    case action
      when AnimeHistoryAction::Episode
        service.new_episode_topic_text(anime, self)

      when AnimeHistoryAction::Anons
        service.new_anons_topic_text(anime, self)

      when AnimeHistoryAction::Release
        service.new_release_topic_text(anime, self)

      when AnimeHistoryAction::Ongoing
        service.new_ongoing_topic_text(anime, self)
    end
  end

  # создание новости о новом эпизоде
  def self.create_for_new_episode(anime, pubDate)
    AnimeNews.find_by(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Episode,
      value: anime.episodes_aired.to_s,
    ) || AnimeNews.create(
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
    AnimeNews.find_or_create_by(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Anons,
      generated: true
    )
  end

  # создание новости о новом онгоинге
  def self.create_for_new_ongoing(anime)
    AnimeNews.find_or_create_by(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Ongoing,
      generated: true
    )
  end

  # создание новости о новом релизе
  def self.create_for_new_release(anime)
    old_release = (anime.released_on && anime.released_on + 2.weeks < DateTime.now) ||
                  (anime.released_on == nil && anime.aired_on && anime.aired_on + 2.weeks < DateTime.now)

    last_episode_history = AnimeNews.where(linked_id: anime.id, linked_type: anime.class.name, action: AnimeHistoryAction::Episode).last
    entry = AnimeNews.find_by(linked_id: anime.id, linked_type: anime.class.name, action: AnimeHistoryAction::Release) || AnimeNews.create(
      linked_id: anime.id,
      linked_type: anime.class.name,
      action: AnimeHistoryAction::Release,
      generated: true,
      processed: old_release,
      created_at: old_release ? anime.released_on : DateTime.now
    )

    anime.released_on = entry.created_at
    entry
  end

  def to_s(type=:short)
    case self.action
      when AnimeHistoryAction::Episode
        "#{self.value} эпизод"

      when AnimeHistoryAction::Anons
        if type == :normal
          if self.anime.aired_on
            if self.anime.aired_on.day == 1 && self.anime.aired_on.month == 1
              "Анонсировано на %d год" % self.anime.aired_on.year
            else
              "Анонсировано на %s года" % Russian::strftime(self.anime.aired_on, "%d %B %Y").sub(/\b0(\d)\b/, '\1')
            end
          else
            "Анонсировано, пока без даты"
          end
        elsif type == :full
          if self.anime.aired_on
            if self.anime.aired_on.day == 1 && self.anime.aired_on.month == 1
              "Выход %s на %d год" % [["запланирован", "назначен", "объявлен", "планируется"].sample, self.anime.aired_on.year]
            else
              "Дата выхода %s на %s года" % [["запланирована", "назначена", "объявлена", "планируется"].sample, Russian::strftime(self.anime.aired_on, "%d %B %Y").sub(/\b0(\d)\b/, '\1')]
            end
          else
            ["Дата выхода пока не известна", "Дата выхода пока не объявлена"].sample
          end
        else
          "Анонс"
        end

      when AnimeHistoryAction::Ongoing
        if type == :normal
          "Начало показов"
        else
          "Онгоинг"
        end

      when AnimeHistoryAction::Release
        if type == :normal
          "Завершение показов"
        else
          "Релиз"
        end

      else
        title
    end
  end
end
