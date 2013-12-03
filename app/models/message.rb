# TODO: refactor src в from_id, а dst в to_id
class Message < ActiveRecord::Base
  belongs_to :src, polymorphic: true
  belongs_to :dst, polymorphic: true
  belongs_to :linked, polymorphic: true

  # откменяю проверку, т.к. могут быть уведомления по AnimeHistory
  #validates_presence_of :body

  validates_presence_of :src
  validates_presence_of :dst

  before_create :filter_quotes
  before_save :antispam

  cattr_writer :antispam
  # включен ли антиспам
  @@antispam = true

  # выполнение кода без антиспама
  def self.wo_antispam(&block)
    @@antispam = false
    val = yield
    @@antispam = true
    val
  end

  # Защита от спама
  def antispam
    return unless @@antispam
    return unless src_type == 'User' && dst_type == 'User'
    return if id != nil
    return if src_type == 'User' && BotsService.posters.include?(src_id)
    return if kind == MessageType::Notification
    return if kind == MessageType::GroupRequest

    prior_comment = Message.includes(:src)
        .includes(:dst)
        .where(src_id: src_id)
        .order('id desc')
        .first

    if prior_comment && DateTime.now.to_i - prior_comment.created_at.to_i < 15
      interval = 15 - (DateTime.now.to_i - prior_comment.created_at.to_i)
      errors['created_at'] = 'Защита от спама. Попробуйте снова через %d %s.' % [interval, Russian.p(interval, 'секунду', 'секунды', 'секунд')]
      return false
    end
  end

  def new?(params)
    [
     'inbox',
     'news',
     'notifications'
    ].include?(params[:type]) && !self.read
  end

  # фильтрафия цитирования более двух уровней вложенности
  def filter_quotes
    self.body = QuoteExtractor.filter(self.body, 2) if self.body
  end

  def subject
    self.kind == MessageType::GroupRequest ? self[:subject].to_i : self[:subject]
  end

  # методы для совместимости с интерфейсом Comment
  def user
    self.src
  end
  def user_id
    self.src_id
  end
  def commentable_type
    self.dst_type
  end
  def commentable_id
    self.dst_id
  end
  def can_be_edited_by?(user)
    false
  end
  def can_be_deleted_by?(user)
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

  #def validate
    #errors[:subject] = "Не может быть пустым" if (!self.subject || self.subject == "") && [MessageType::Private].include?(self.kind)
  #end
end
