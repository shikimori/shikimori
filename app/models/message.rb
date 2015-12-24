# TODO: refactor kind = MessageType::... в enumerize kind или в enum kind
class Message < ActiveRecord::Base
  include Antispam
  # для совместимости с comment
  #attr_accessor :topic_name, :topic_url

  belongs_to :from, class_name: User.name
  belongs_to :to, class_name: User.name
  belongs_to :linked, polymorphic: true

  # откменяю проверку, т.к. могут быть уведомления по AnimeHistory
  #validates_presence_of :body

  validates :from, :to, presence: true
  validates :body, presence: true, if: -> { kind == MessageType::Private }

  after_create :send_email

  # Защита от спама
  def check_antispam
    return unless with_antispam?
    return if id != nil
    return if BotsService.posters.include?(from_id)
    return if kind == MessageType::Notification
    return if kind == MessageType::ClubRequest
    return if User::ADMINS.include?(from_id)

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

  def html_body
    BbCodeFormatter.instance.format_comment body
  end

  def delete_by user
    if kind == MessageType::Private
      delete_by! user
    else
      destroy!
    end

    self
  end

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
      update! is_deleted_by_from: true
    elsif to == user
      update! is_deleted_by_to: true, read: true
    else
      raise ArgumentError, "unknown deleter: #{user}"
    end
  end

  def send_email
    EmailNotifier.instance.private_message(self) if kind == MessageType::Private
  end
end
