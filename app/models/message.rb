# TODO: refactor kind = MessageType::... into enumerize kind or into enum kind
class Message < ApplicationRecord
  include AntispamConcern
  include Translation

  belongs_to :from, class_name: 'User'
  belongs_to :to, class_name: 'User', touch: true
  belongs_to :linked, polymorphic: true, optional: true

  antispam(
    interval: 3.seconds,
    per_day: 400,
    scope: -> { where kind: MessageType::PRIVATE },
    disable_if: -> { kind != MessageType::PRIVATE || from.bot? },
    user_id_key: :from_id
  )

  validates :body,
    presence: true,
    length: { minimum: 2, maximum: 20_000 },
    if: -> { kind == MessageType::PRIVATE && will_save_change_to_body? }

  before_create :check_spam_abuse,
    if: -> {
      kind == MessageType::PRIVATE && !from.bot? && will_save_change_to_body?
    }
  after_create :send_email

  def new? params
    %w[
      inbox
      news
      notifications
    ].include?(params[:type]) && !read
  end

  def html_body
    BbCodes::Text.call body
  end

  def delete_by user
    if kind == MessageType::PRIVATE && to == user && to_id != from_id
      update! is_deleted_by_to: true, read: true
    else
      destroy!
    end

    self
  end

  # for rss feed
  def guid
    "message-#{id}"
  end

  def read?
    read
  end

  # must touch updated_at for all users to invalidate unread_count cache
  def self.import messages, *args
    result = super
    User.where(id: messages.map(&:to_id)).update_all updated_at: Time.zone.now
    result
  end

private

  def check_spam_abuse
    throw :abort unless Messages::CheckSpamAbuse.call(self)

    unless Users::CheckHacked.call(model: self, text: body, user: from)
      throw :abort
    end
  end

  def send_email
    return unless kind == MessageType::PRIVATE

    EmailNotifier.instance.private_message self
  end
end
