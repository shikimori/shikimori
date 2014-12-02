class Message < ActiveRecord::Base
  # для совместимости с comment
  attr_accessor :topic_name, :topic_url

  belongs_to :from, class_name: User.name
  belongs_to :to, class_name: User.name
  belongs_to :linked, polymorphic: true

  # откменяю проверку, т.к. могут быть уведомления по AnimeHistory
  #validates_presence_of :body

  validates :from, :to, presence: true
  validates :body, presence: true, if: -> { kind == MessageType::Private }

  before_create :filter_quotes
  before_save :antispam

  cattr_writer :antispam
  # включен ли антиспам
  @@antispam = true

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
    return if User::Admins.include?(from_id)

    prior_comment = Message
      .includes(:from, :to)
      .where(from_id: from_id)
      .order(id: :desc)
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

  def html_body
    BbCodeFormatter.instance.format_comment body
  end

  def delete_by user
    if kind == MessageType::Private
      delete_by! user
    else
      destroy!
    end
  end

  # методы для совместимости с интерфейсом Comment
  #def user
    #from
  #end
  #def user_id
    #from_id
  #end
  #def commentable_type
    #User.name
  #end
  #def commentable_id
    #to_id
  #end
  #def can_be_edited_by? user
    #false
  #end
  #def can_be_deleted_by? user
    #false
  #end
  #def html
    #false
  #end
  #def viewed?
    #true
  #end

  #def offtopic?
    #false
  #end

  # идентификатор для рсс ленты
  def guid
    "message-#{self.id}"
  end

  def read?
    read
  end

private
  def delete_by! user
    if from == user
      update! src_del: true
    elsif to == user
      update! dst_del: true, read: true
    else
      raise ArgumentError, "unknown deleter: #{user}"
    end
  end
end
