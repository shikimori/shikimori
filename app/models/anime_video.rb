class AnimeVideo < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime
  belongs_to :author,
    class_name: AnimeVideoAuthor.name,
    foreign_key: :anime_video_author_id

  enumerize :kind, in: [:raw, :subtitles, :fandub, :unknown], predicates: true
  enumerize :language, in: [:russian, :english], predicates: true

  validates :anime, presence: true
  validates :url, presence: true, url: true
  validates :source, presence: true
  validates :episode, numericality: { greater_than_or_equal_to: 0 }

  before_save :check_ban

  default_scope { where state: ['working', 'uploaded'] }

  state_machine :state, initial: :working do
    state :working
    state :uploaded
    state :broken
    state :wrong
    state :banned

    event :broken do
      transition working: :broken
    end
    event :wrong do
      transition working: :wrong
    end
    event :ban do
      transition working: :banned
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

private
  def check_ban
    self.state = 'banned' if hosting == 'kiwi.kz'
  end
end
