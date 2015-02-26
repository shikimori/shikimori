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

  validates :anime, :source, :kind, presence: true
  validates :url, presence: true, url: true, uniqueness: { scope: :anime_id }
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  before_save :check_ban
  before_save :check_copyright
  after_create :create_episode_notificaiton, if: -> { !unknown? && single? }

  PLAY_CONDITION = "animes.rating not in ('#{Anime::ADULT_RATINGS.join "','"}') and animes.censored = false"
  XPLAY_CONDITION = "animes.rating in ('#{Anime::ADULT_RATINGS.join "','"}') or animes.censored = true"

  scope :allowed_play, -> { available.joins(:anime).where(PLAY_CONDITION) }
  scope :allowed_xplay, -> { available.joins(:anime).where(XPLAY_CONDITION) }

  scope :available, -> { where state: ['working', 'uploaded'] }

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
      transition [:working, :uploaded] => :broken
    end
    event :wrong do
      transition [:working, :uploaded] => :wrong
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
    event :uploaded do
      transition uploaded: :working
    end

    after_transition working: [:broken, :wrong, :banned], if: :single?, do: :remove_episode_notification
  end

  def hosting
    parts = URI.parse(url).host.split('.')
    domain = "#{parts[-2]}.#{parts[-1]}"
    domain == 'vkontakte.ru' ? 'vk.com' : domain
  end

  def vk?
    hosting == 'vk.com'
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
    @uploader ||= if uploaded? || working?
      AnimeVideoReport.where(anime_video_id: id, kind: 'uploaded').last.try(:user)
    end
  end

  def author_name
    author.try :name
  end

  def author_name= name
    self.author = AnimeVideoAuthor.find_or_create_by name: name.to_s.strip
  end

  def single?
    AnimeVideo.where(anime_id: anime_id, episode: episode, kind: kind, language: language).count == 1
  end

private
  def check_ban
    self.state = 'banned' if hosting == 'kiwi.kz'
  end

  def check_copyright
    self.state = 'copyrighted' if copyright_ban?
  end

  # FIX: extract create_episode_notificaiton and remove_episode_notification to service.
  def create_episode_notificaiton
    EpisodeNotification
      .find_or_initialize_by(anime_id: anime_id, episode: episode)
      .update("is_#{kind}" => true)
  end

  def remove_episode_notification
    notify = EpisodeNotification
      .where(anime_id: anime_id, episode: episode)
      .first
    !unknown? && notify && notify.update("is_#{kind}" => false)
  end
end
