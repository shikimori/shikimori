#TODO : проверить необходимость метода allowed?
#TODO : вынести методы относящиеся ко вью в декоратор.
class AnimeVideo < ApplicationRecord
  # для Versions
  SIGNIFICANT_FIELDS = []

  belongs_to :anime
  belongs_to :author,
    class_name: AnimeVideoAuthor.name,
    foreign_key: :anime_video_author_id
  has_many :reports, class_name: AnimeVideoReport.name, dependent: :destroy

  enumerize :kind,
    in: [:fandub, :unknown, :subtitles, :raw],
    default: :unknown,
    predicates: true
  enumerize :language,
    in: [:russian, :unknown, :original, :english],
    default: :unknown,
    predicates: { prefix: true }
  enumerize :quality,
    in: [:bd, :web, :dvd, :tv, :unknown],
    default: :unknown,
    predicates: { prefix: true }

  validates :anime, :source, :kind, presence: true
  validates :url,
    presence: true,
    anime_video_url: true,
    if: -> { new_record? || changes['url'] }
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  before_save :check_banned_hostings
  before_save :check_copyrighted_animes
  after_create :create_episode_notificaiton, if: :single?

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
    animes.censored = false and
    not #{ADULT_OVA_CONDITION}
  SQL
  XPLAY_CONDITION = <<-SQL.squish
    animes.rating = '#{Anime::ADULT_RATING}' or
    animes.censored = true or
    #{ADULT_OVA_CONDITION}
  SQL

  scope :allowed_play, -> { available.joins(:anime).where(PLAY_CONDITION) }
  scope :allowed_xplay, -> { available.joins(:anime).where(XPLAY_CONDITION) }

  scope :available, -> { where state: %w(working uploaded) }

  CopyrightBanAnimeIDs = [-1] # 10793

  state_machine :state, initial: :working do
    state :working
    state :uploaded
    state :rejected
    state :broken
    state :wrong
    state :banned
    state :copyrighted

    event :broken do
      transition [:working, :uploaded, :broken, :rejected] => :broken
    end
    event :wrong do
      transition [:working, :uploaded, :wrong, :rejected] => :wrong
    end
    event :ban do
      transition :working => :banned
    end
    event :reject do
      transition [:uploaded, :wrong, :broken, :banned] => :rejected
    end
    event :work do
      transition [:uploaded, :broken, :wrong, :banned] => :working
    end
    event :uploaded do
      transition [:working, :uploaded] => :working
    end

    after_transition [:working, :uploaded] => [:broken, :wrong, :banned],
      if: :single?,
      do: :remove_episode_notification

    after_transition [:working, :uploaded] => [:broken, :wrong, :banned],
      do: :process_reports
  end

  def url= value
    video_url = Url.new(value).with_http.to_s if value.present?
    extracted_url =
      VideoExtractor::UrlExtractor.call video_url if video_url.present?

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
    hosting == 'smotret-anime.ru'
  end

  def allowed?
    working? || uploaded?
  end

  def copyright_ban?
    CopyrightBanAnimeIDs.include? anime_id
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
    self.author = AnimeVideoAuthor.find_or_create_by name: name
  end

  def single?
    AnimeVideo
      .where(anime_id: anime_id, episode: episode, kind: kind, language: language)
      .one?
  end

  # Debug only
  def page_url
    "#{AnimeOnlineDomain::HOST}/animes/#{anime_id}/video_online/#{episode}/#{id}"
  end

private

  def check_banned_hostings
    self.state = 'banned' if hosting == 'kiwi.kz'
  end

  def check_copyrighted_animes
    self.state = 'copyrighted' if copyright_ban?
  end

  # FIX: extract create_episode_notificaiton and remove_episode_notification to service.
  def create_episode_notificaiton
    EpisodeNotification
      .find_or_initialize_by(anime_id: anime_id, episode: episode)
      .update("is_#{kind}" => true)
  end

  def remove_episode_notification
    EpisodeNotification
      .where(anime_id: anime_id, episode: episode)
      .update_all("is_#{kind}" => false)
  end

  def process_reports
    reports.each do |report|
      if (report.wrong? || report.broken? || report.other?) && report.pending?
        report.accept_only! BotsService.get_poster
      elsif report.uploaded? && report.can_post_reject?
        report.post_reject!
      end
    end
  end
end
