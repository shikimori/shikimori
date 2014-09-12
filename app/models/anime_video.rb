#TODO : проверить необходимость метода allowed?
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
  validates :url, presence: true, url: true, uniqueness: { scope: :anime_id }
  validates :source, presence: true
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  before_save :check_ban
  before_save :check_copyright

  scope :allowed_play, -> {
    worked
      .joins(:anime)
      .where('animes.rating not in (?)', Anime::ADULT_RATINGS)
      .where('animes.censored = false')
  }

  scope :allowed_xplay, -> {
    worked
      .joins(:anime)
      .where('animes.rating in (?) or animes.censored = true', Anime::ADULT_RATINGS)
  }

  scope :worked, -> { where state: ['working', 'uploaded'] }

  CopyrightBanAnimeIDs = [10793]

  state_machine :state, initial: :working do
    state :working
    state :uploaded
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
    "#{url}#{url.include?('?') ? '&' : '?' }quality=480"
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
end
