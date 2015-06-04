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

  ACTIVE_DURATION = 60.days

  def duration= value
    self[:duration] = BanDuration.new(value).to_i unless value.nil?
  end

  def duration
    BanDuration.new self[:duration] unless self[:duration].nil?
  end

  def suggest_duration
    bans_count = UsersQuery.new(user_id: user_id).bans_count

    duration = if bans_count > 15
      '1w 3d 12h'
    elsif bans_count <= 5
      30 + 30 * ((bans_count ** 3) / 2 - 1)
    else
      60 * bans_count ** 2
    end

    BanDuration.new(duration).to_s
  end

  def warning?
    duration.zero?
  end

  def set_user
    self.user_id = comment.user_id unless user_id || !comment
  end

  def message
    if warning?
      "предупреждение. #{BbCodeFormatter.instance.format_comment reason}."
    else
      "бан на #{duration.humanize}. #{BbCodeFormatter.instance.format_comment reason}."
    end.sub /\.+\Z/, '.'
  end

  # callbacks
  def ban_user
    return if warning?
    user.update_column :read_only_at, [user.read_only_at || DateTime.now, DateTime.now].max + duration.minutes
  end

  def notify_user
    Message.create_wo_antispam!(
      from_id: moderator.id,
      to_id: user.id,
      kind: warning? ? MessageType::Warned : MessageType::Banned,
      linked: self
    )
  end

  def mention_in_comment
    return if comment.nil?
    updated_body = (comment.body.strip + "\n\n[ban=#{id}]").gsub(/(\[ban=\d+\])\s+(\[ban=\d+\])/, '\1\2')
    comment.update_column :body, updated_body
  end

  def accept_abuse_request
    abuse_request.take! moderator if abuse_request_id.present?
  end
end
