# TODO : проверить необходимость метода allowed?
# TODO : вынести методы относящиеся ко вью
class AnimeVideo < ApplicationRecord
  # for Versions
  SIGNIFICANT_MAJOR_FIELDS = []
  SIGNIFICANT_MINOR_FIELDS = []

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
    anime_video_url: true,
    if: -> { new_record? || changes['url'] }
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  # before_save :check_copyrighted_authors,
  #   if: :anime_video_author_id_changed?
  before_save :check_banned_hostings
  before_save :check_copyrighted_animes

  after_create :create_episode_notificaiton, unless: -> {
    anime.anons? || any_videos?
  }
  after_destroy :rollback_episode_notification, unless: :any_videos?
  after_update :check_episode_notification, if: -> {
    saved_change_to_episode? ||
      saved_change_to_kind? ||
      saved_change_to_anime_id?
  }

  scope :allowed_play, -> { available.joins(:anime).where(PLAY_CONDITION) }
  scope :allowed_xplay, -> { available.joins(:anime).where(XPLAY_CONDITION) }

  scope :available, -> { where state: %w[working uploaded] }

  COPYRIGHT_BAN_ANIME_IDS = [-1]

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

    after_transition(
      %i[working uploaded] => %i[broken wrong banned_hosting],
      unless: :any_videos?,
      do: :rollback_episode_notification
    )
    after_transition(
      %i[working uploaded] => %i[broken wrong banned_hosting],
      do: :process_reports
    )
    after_transition(
      uploaded: :working,
      do: :create_episode_notificaiton,
      if: ->(anime_video) { anime_video.anime.anons? && !anime_video.any_videos? }
    )
  end

  def url= value
    video_url = Url.new(value).with_http.to_s if value.present?
    if video_url.present?
      extracted_url = VideoExtractor::PlayerUrlExtractor.call video_url
    end

    if extracted_url.present?
      super Url.new(extracted_url).with_http.to_s
    else
      super extracted_url
    end
  end

  def hosting
    AnimeOnline::ExtractHosting.call url
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

  def copyright_ban?
    COPYRIGHT_BAN_ANIME_IDS.include? anime_id
  end

  def uploader
    @uploader ||= AnimeVideoReport.find_by(
      anime_video_id: id,
      kind: 'uploaded'
    )&.user
  end

  def author_name
    author.try :name
  end

  def author_name= name
    fixed_name = name&.strip

    self.author =
      if fixed_name.present?
        AnimeVideoAuthor.find_or_create_by name: fixed_name
      end
  end

  def any_videos?(
    anime_id: self.anime_id,
    episode: self.episode,
    kind: self.kind
  )
    AnimeOnline::SameVideos.call(
      anime_id: anime_id,
      anime_video_id: id,
      episode: episode,
      kind: kind
    ).any?
  end

private

  # def check_copyrighted_authors
  #   return unless author_name&.match? COPYRIGHTED_AUTHORS

  #   errors.add :base, 'Видео этого автора не могут быть загружены на сайт'
  #   throw :abort
  # end

  def check_banned_hostings
    self.state = 'banned_hosting' if BANNED_HOSTINGS.include? hosting
  end

  def check_copyrighted_animes
    self.state = 'copyrighted' if copyright_ban?
  end

  def create_episode_notificaiton
    EpisodeNotification::Create.call(
      anime_id: anime_id,
      episode: episode,
      kind: kind
    )
  end

  def rollback_episode_notification
    EpisodeNotification::Rollback.call(
      anime_id: anime_id,
      episode: episode,
      kind: kind
    )
  end

  def check_episode_notification
    any_new_videos = any_videos?(
      anime_id: saved_changes.dig('anime_id', 1) || anime_id,
      episode: saved_changes.dig('episode', 1) || episode,
      kind: saved_changes.dig('kind', 1) || kind
    )

    any_old_videos = any_videos?(
      anime_id: saved_changes.dig('anime_id', 0) || anime_id,
      episode: saved_changes.dig('episode', 0) || episode,
      kind: saved_changes.dig('kind', 0) || kind
    )

    # must be before EpisodeNotification::Create because in
    # Anime::RollbackEpisode notifications with episode >= @episode are deleted
    unless any_old_videos
      EpisodeNotification::Rollback.call(
        anime_id: saved_changes.dig('anime_id', 0) || anime_id,
        episode: saved_changes.dig('episode', 0) || episode,
        kind: saved_changes.dig('kind', 0) || kind
      )
    end

    unless any_new_videos
      EpisodeNotification::Create.call(
        anime_id: saved_changes.dig('anime_id', 1) || anime_id,
        episode: saved_changes.dig('episode', 1) || episode,
        kind: saved_changes.dig('kind', 1) || kind
      )
    end
  end

  def process_reports
    reports.each do |report|
      process_report report
    end
  end

  def process_report report
    if (report.wrong? || report.broken? || report.other?) && report.pending?
      report.accept_only! BotsService.get_poster
    elsif report.uploaded? && report.can_post_reject?
      report.post_reject!
    end
  end
end
