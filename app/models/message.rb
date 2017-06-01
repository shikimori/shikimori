# TODO: refactor kind = MessageType::... в enumerize kind или в enum kind
class Message < ApplicationRecord
  include Translation
  include Antispam

  # для совместимости с comment
  #attr_accessor :topic_name, :topic_url

  belongs_to :from, class_name: User.name
  belongs_to :to, class_name: User.name
  belongs_to :linked, polymorphic: true

  # отменяю проверку, т.к. могут быть уведомления по AnimeHistory
  #validates_presence_of :body

  validates :from, :to, presence: true
  validates :body,
    presence: true,
    if: ->(message) { kind == MessageType::Private }

  before_create :check_spam_abuse
  after_create :send_email
  after_create :send_push_notifications

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

    if prior_comment && Time.zone.now.to_i - prior_comment.created_at.to_i < 15
      interval = 15 - (Time.zone.now.to_i - prior_comment.created_at.to_i)
      seconds = i18n_i('datetime.second', interval, :accusative)

      errors.add(
        :created_at ,
        i18n_t('antispam', interval: interval, seconds: seconds)
      )
      throw :abort
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
    if kind == MessageType::Private && to == user
      update! is_deleted_by_to: true, read: true
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

  def check_spam_abuse
    Messages::CheckSpamAbuse.call self if kind == MessageType::Private
  end

  def send_email
    return unless kind == MessageType::Private
    EmailNotifier.instance.private_message self
  end

  def send_push_notifications
    return unless to.active?

    to.devices.each do |device|
      PushNotification.perform_async id, device.id
    end
  end
end
