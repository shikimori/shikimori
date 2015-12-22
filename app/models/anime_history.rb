class AnimeHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :anime
  has_one :topic, dependent: :destroy
  has_many :messages, dependent: :destroy
  belongs_to :topic

  after_create :create_topic

  def to_s type=:short
    case self.action
      when AnimeHistoryAction::Episode
        "%d эпизод" % self.value

      when AnimeHistoryAction::Anons
        if type == :normal
          if self.anime.aired
            if self.anime.aired.day == 1 && self.anime.aired.month == 1
              "Анонсировано на %d год" % self.anime.aired.year
            else
              "Анонсировано на %s года" % Russian::strftime(self.anime.aired, "%d %B %Y").sub(/\b0(\d)\b/, '\1')
            end
          else
            "Анонсировано, пока без даты"
          end
        elsif type == :full
          if self.anime.aired
            if self.anime.aired.day == 1 && self.anime.aired.month == 1
              "Выход запланирован на %d год" % self.anime.aired.year
            else
              "Дата выхода запланирована на %s года" % Russian::strftime(self.anime.aired, "%d %B %Y").sub(/\b0(\d)\b/, '\1')
            end
          else
            "Дата выхода пока не известна"
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

      when AnimeHistoryAction::Released
        if type == :normal
          "Завершение показов"
        else
          "Релиз"
        end
    end
  end

  # создание топика для записи истории
  def create_topic
    raise "topic already exists for anime_history_id=%d" % [self.id] if self.topic_id != 0
    anime_history_processor = AnimeHistoryService.new
    case self.action
      when AnimeHistoryAction::Episode
        return

      when AnimeHistoryAction::Anons
        subject = anime_history_processor.new_anons_topic_subject(self.anime, self)
        body = anime_history_processor.new_anons_topic_text(self.anime, self)

      when AnimeHistoryAction::Released
        subject = anime_history_processor.new_release_topic_subject(self.anime, self)
        body = anime_history_processor.new_release_topic_text(self.anime, self)

      when AnimeHistoryAction::Ongoing
        subject = anime_history_processor.new_ongoing_topic_subject(self.anime, self)
        body = anime_history_processor.new_ongoing_topic_text(self.anime, self)
    end

    topic, comment = Topic.custom_create({title: subject,
                                          forum_id: Forum::ANIME_NEWS_ID,
                                          created_at: self.created_at},
                                         {body: body,
                                          created_at: self.created_at},
                                         BotsService.get_poster.id)
    raise "can't create topic for anime_history_id=%d" % [self.id] if topic == nil || topic.id == nil
    raise "can't create comment for anime_history_id=%d" % [self.id] and topic.destroy if comment == nil || comment.id == nil
    self.topic = topic
    self.save
  end
end
