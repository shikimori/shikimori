class Message < ActiveRecord::Base
  belongs_to :from, class_name: User.name
  belongs_to :to, class_name: User.name
  belongs_to :linked, polymorphic: true

  # откменяю проверку, т.к. могут быть уведомления по AnimeHistory
  #validates_presence_of :body

  validates_presence_of :from
  validates_presence_of :to

  before_create :filter_quotes
  before_save :antispam

  cattr_writer :antispam
  # включен ли антиспам
  @@antispam = true

  scope :complaint_videos, -> { Message.where to_id: User::Blackchestnut_ID, subject: [:broken_video.to_s, :wrong_video.to_s] }

  # выполнение кода без антиспама
  def self.wo_antispam &block
    @@antispam = false
    val = yield
    @@antispam = true
    val
  end

  # Защита от спама
  def antispam
    return unless @@antispam
    return if id != nil
    return if BotsService.posters.include?(from_id)
    return if kind == MessageType::Notification
    return if kind == MessageType::GroupRequest

    prior_comment = Message
      .includes(:from, :to)
      .where(from_id: from_id)
      .order { id.desc }
      .first

    if prior_comment && DateTime.now.to_i - prior_comment.created_at.to_i < 15
      interval = 15 - (DateTime.now.to_i - prior_comment.created_at.to_i)
      errors['created_at'] = 'Защита от спама. Попробуйте снова через %d %s.' % [interval, Russian.p(interval, 'секунду', 'секунды', 'секунд')]
      return false
    end
  end

  def new? params
    [
     'inbox',
     'news',
     'notifications'
    ].include?(params[:type]) && !self.read
  end

  # фильтрафия цитирования более двух уровней вложенности
  def filter_quotes
    self.body = QuoteExtractor.filter(body, 2) if body
  end

  def subject
    self.kind == MessageType::GroupRequest ? self[:subject].to_i : self[:subject]
  end

  # методы для совместимости с интерфейсом Comment
  def user
    from
  end
  def user_id
    from_id
  end
  def commentable_type
    User.name
  end
  def commentable_id
    to_id
  end
  def can_be_edited_by? user
    false
  end
  def can_be_deleted_by? user
    false
  end
  def html
    false
  end
  def viewed?
    true
  end

  def offtopic?
    false
  end

  # идентификатор для рсс ленты
  def guid
    "message-#{self.id}"
  end
end
