class AnimeVideo < ApplicationRecord # rubocop:disable all
  R_OVA_EPISODES = 2
  ADULT_OVA_CONDITION = <<-SQL.squish
    (
      animes.rating = '#{Anime::SUB_ADULT_RATING}' and
      (
        (animes.kind = 'ova' and animes.episodes <= #{R_OVA_EPISODES}) or
        animes.kind = 'Special'
      )
    )
  SQL
  PLAY_CONDITION = <<-SQL.squish
    animes.rating != '#{Anime::ADULT_RATING}' and
    animes.is_censored = false and
    not #{ADULT_OVA_CONDITION}
  SQL
  XPLAY_CONDITION = <<-SQL.squish
    animes.rating = '#{Anime::ADULT_RATING}' or
    animes.is_censored = true or
    #{ADULT_OVA_CONDITION}
  SQL

  # kiwi.kz dailymotion.com myvi.ru myvi.tv - banned in RF
  # rutube.ru - banned play.shikimori.org for some reason
  BANNED_HOSTINGS = %w[kiwi.kz dailymotion.com myvi.ru play.aniland.org rutube.ru]
  # COPYRIGHTED_AUTHORS = /wakanim/i # |crunchyroll|crunchy|FreakCrSuBuS

  belongs_to :anime
  has_many :reports, class_name: AnimeVideoReport.name, dependent: :destroy

  enumerize :kind,
    in: %i[fandub unknown subtitles raw],
    default: :unknown,
    predicates: true
  enumerize :language,
    in: %i[russian unknown original english],
    default: :unknown,
    predicates: { prefix: true }
  enumerize :quality,
    in: %i[bd dvd web tv unknown],
    default: :unknown,
    predicates: { prefix: true }

  validates :anime, :source, :kind, presence: true
  validates :url,
    presence: true,
    if: -> { new_record? || changes['url'] }
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  # before_save :check_copyrighted_authors,
  #   if: :anime_video_author_id_changed?

  state_machine :state, initial: :working do
    state :working
    state :uploaded
    state :rejected
    state :broken
    state :wrong
    state :copyrighted
    state :banned_hosting

    event :broken do
      transition %i[working uploaded broken rejected] => :broken
    end
    event :wrong do
      transition %i[working uploaded wrong rejected] => :wrong
    end
    event :ban do
      transition %i[working uploaded] => :banned_hosting
    end
    event :reject do
      transition %i[uploaded wrong broken banned_hosting] => :rejected
    end
    event :work do
      transition %i[uploaded broken wrong banned_hosting] => :working
    end
    event :uploaded do
      transition %i[working uploaded] => :working
    end
  end

  def hosting
    VideoExtractor::ExtractHosting.call url
  end

  def vk?
    hosting == 'vk.com'
  end

  def smotret_anime?
    hosting == 'smotretanime.ru'
  end

  def allowed?
    working? || uploaded?
  end
end
