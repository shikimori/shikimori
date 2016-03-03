class Topic < Entry
  include Moderatable
  include Antispam

  FORUM_IDS = {
    'Anime' => 1,
    'Manga' => 1,
    'Character' => 1,
    'Person' => 1,
    'Club' => Forum::CLUBS_ID,
    'Review' => 12,
    'Contest' => Forum::CONTESTS_ID,
    'CosplayGallery' => Forum::COSPLAY_ID
  }

  belongs_to :anime_history
  validates :title, :body, presence: true, unless: :generated?

  def title
    self.user && self.user.bot? && self[:title] ? self[:title].html_safe : self[:title]
  end
end
