class Ban < ActiveRecord::Base
  belongs_to :user
  belongs_to :moderator, class_name: User.name
  belongs_to :comment, touch: true
  belongs_to :abuse_request, touch: true

  validates :user, :moderator, presence: true
  validates :duration, :reason, presence: true
  #validates :comment, :abuse_request, presence: true

  before_validation :set_user
  after_create :ban_user
  after_create :notify_user
  after_create :mention_in_comment
  after_create :accept_abuse_request

  ACTIVE_DURATION = 3.month

  def duration= value
    self[:duration] = BanDuration.new(value).to_i unless value.nil?
  end

  def duration
    BanDuration.new self[:duration] unless self[:duration].nil?
  end

  def suggest_duration
    minutes = 30 + 30 * ((UsersQuery.new(user_id: user_id).bans_count ** 3) /2 - 1)
    BanDuration.new(minutes).to_s
  end

  def warning?
    duration.zero?
  end

  def set_user
    self.user_id = comment.user_id unless user_id || !comment
  end

  def message
    if warning?
      "предупреждение. #{reason.strip}."
    else
      "бан на #{duration.humanize}. #{reason.strip}."
    end.sub /\.+\Z/, '.'
  end

# callbacks
  def ban_user
    return if warning?
    user.update_column :read_only_at, [user.read_only_at || DateTime.now, DateTime.now].max + duration.minutes
  end

  def notify_user
    Message.wo_antispam do
      Message.create!({
        from_id: moderator.id,
        to_id: user.id,
        kind: warning? ? MessageType::Warned : MessageType::Banned,
        linked: self
      })
    end
  end

  def mention_in_comment
    return if comment.nil?

    comment.body = (comment.body.strip + "\n\n[ban=#{id}]").gsub /(\[ban=\d+\])\s+(\[ban=\d+\])/, '\1\2'
    comment.save! validate: false
  end

  def accept_abuse_request
    abuse_request.take! moderator if abuse_request_id.present?
  end
end
