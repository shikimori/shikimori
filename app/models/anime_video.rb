class AnimeVideo < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime

  belongs_to :author,
    class_name: AnimeVideoAuthor.name,
    foreign_key: :anime_video_author_id

  enumerize :kind, in: [:raw, :subtitles, :fandub, :unknown], predicates: true
  enumerize :language, in: [:russian, :english], predicates: true

  validates :anime, presence: true
  validates :url, presence: true
  validates :source, presence: true

  # ... -> broken_video, wrong_video, veri
  #state_machine :state, initial: :... do
    #state :...
    #state :pending
    #state :broken
    #state :wrong

    #event :mark_broken do
      #transition ...: :broken
    #end

    #event :mark_wrong do
      #transition ...: :wrong
    #end
  #end

  def hosting
    parts = URI.parse(url).host.split('.')
    domain = "#{parts[-2]}.#{parts[-1]}"
    domain == 'vkontakte.ru' ? 'vk.com' : domain
  end
end
