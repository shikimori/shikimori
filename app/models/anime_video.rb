#TODO : проверить необходимость метода allowed?
#TODO : вынести методы относящиеся ко вью в декоратор.
class AnimeVideo < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime
  belongs_to :author,
    class_name: AnimeVideoAuthor.name,
    foreign_key: :anime_video_author_id
  has_many :reports,
    class_name: AnimeVideoReport.name,
    dependent: :destroy

  enumerize :kind, in: [:raw, :subtitles, :fandub, :unknown], predicates: true
  enumerize :language, in: [:russian, :english], predicates: true

  validates :anime, presence: true
  validates :url, presence: true, url: true
  validates :source, presence: true
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  before_save :check_ban
  before_save :check_copyright
  after_create :notify

  PLAY_CONDITION = "animes.rating not in ('#{Anime::ADULT_RATINGS.join "','"}') and animes.censored = false"
  XPLAY_CONDITION = "animes.rating in ('#{Anime::ADULT_RATINGS.join "','"}') or animes.censored = true"

  scope :allowed_play, -> { worked.joins(:anime).where(PLAY_CONDITION) }
  scope :allowed_xplay, -> { worked.joins(:anime).where(XPLAY_CONDITION) }

  scope :worked, -> { where state: ['working', 'uploaded'] }

  CopyrightBanAnimeIDs = [] # 10793

  state_machine :state, initial: :working do
    state :working do
      validates :url, uniqueness: { scope: :anime_id }
    end
    state :uploaded do
      validates :url, uniqueness: { scope: :anime_id }
    end
    state :rejected
    state :broken
    state :wrong
    state :banned
    state :copyrighted

    event :broken do
      transition working: :broken
    end
    event :wrong do
      transition working: :wrong
    end
    event :ban do
      transition working: :banned
    end
    event :reject do
      transition [:uploaded, :wrong, :broken, :banned] => :rejected
    end
    event :work do
      transition [:uploaded, :broken, :wrong, :banned] => :working
    end
  end

  def hosting
    parts = URI.parse(url).host.split('.')
    domain = "#{parts[-2]}.#{parts[-1]}"
    domain == 'vkontakte.ru' ? 'vk.com' : domain
  end

  def vk?
    hosting == 'vk.com'
  end

  def player_url
    if vk? && reports.any? {|r| r.broken? }
      "#{url}#{url.include?('?') ? '&' : '?' }quality=360"
    else
      url
    end
  end

  def allowed?
    working? || uploaded?
  end

  def copyright_ban?
    CopyrightBanAnimeIDs.include? anime_id
  end

  def mobile_compatible?
    vk?
  end

  def uploader
    if uploaded?
      @uploader ||= AnimeVideoReport.where(anime_video_id: id, kind: 'uploaded').last.try(:user)
    end
  end

private
  def check_ban
    self.state = 'banned' if hosting == 'kiwi.kz'
  end

  def check_copyright
    self.state = 'copyrighted' if copyright_ban?
  end

  def notify
    if !unknown? && AnimeVideo.where(anime_id: anime_id, episode: episode, kind: kind, language: language).count == 1
      notify = EpisodeNotification.where(anime_id: anime_id, episode: episode).first_or_create
      unless notify.send("is_#{kind}")
        notify.send("is_#{kind}=", true)
        notify.save
      end
    end
  end
end
