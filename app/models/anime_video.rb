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

  def hosting
    parts = URI.parse(url).host.split('.')
    "#{parts[-2]}.#{parts[-1]}"
  end
end
