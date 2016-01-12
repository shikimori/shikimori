class Topic < Entry
  include Moderatable
  include Antispam

  belongs_to :anime_history
  validates :title, :body, presence: true, unless: :generated?

  def title
    self.user && self.user.bot? && self[:title] ? self[:title].html_safe : self[:title]
  end
end
