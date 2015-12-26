class Topic < Entry
  include Moderatable
  include Antispam

  belongs_to :anime_history

  validates :title, :text, presence: true

  before_destroy :clear_anime_history

  def title
    self.user && self.user.bot? && self[:title] ? self[:title].html_safe : self[:title]
  end

  def body
    text
  end

  def self.custom_create topic_params, comment_params, user_id
    topic = Topic.new(topic_params)
    topic.permalink = topic.title.permalinked
    topic.user_id = user_id
    topic.text = comment_params[:body]

    topic.save ? topic : nil
  end

private

  def clear_anime_history
    self.anime_history.topic_id = 0 if self.anime_history
  end
end
