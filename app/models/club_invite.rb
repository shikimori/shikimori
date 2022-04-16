class ClubInvite < ApplicationRecord
  belongs_to :club
  belongs_to :src, class_name: 'User'
  belongs_to :dst, class_name: 'User'
  # invite messages
  belongs_to :message, optional: true, dependent: :destroy

  enumerize :status,
    in: Types::ClubInvite::Status.values,
    predicates: true,
    default: Types::ClubInvite::Status[:pending]

  validates :dst_id, uniqueness: {
    scope: %i[club_id status],
    message: ->(key, _model) { I18n.t key }
  }

  before_create :check_banned
  before_create :check_joined

  before_create :check_user_invites_limit
  before_create :check_club_invites_limit

  before_create :cleanup_invites
  after_create :create_message

  USER_INVITES_PER_DAY = 30
  CLUB_INVITES_PER_DAY = 200
  INVITES_LIMIT_EXPIRATION = 1.day

  def accept
    close
    club.join dst unless club.member?(dst) || club.banned?(dst)
  end

  def close
    update status: Types::ClubInvite::Status[:closed]
    message&.update read: true
  end

private

  def create_message
    message = Message.create!(
      kind: MessageType::CLUB_REQUEST,
      from: src,
      to: dst,
      linked: self
    )

    update message: message
  end

  def cleanup_invites
    ClubInvite
      .where(dst_id: dst_id, club_id: club_id)
      .where.not(id: id)
      .destroy_all
  end

  def check_banned
    return unless club.banned? dst
    errors.add :base, :banned
    throw :abort
  end

  def check_joined
    return unless club.member? dst
    errors.add :base, :joined
    throw :abort
  end

  def check_user_invites_limit
    today_invites = ClubInvite
      .where(club_id: club_id, src_id: src_id)
      .where('created_at > ?', INVITES_LIMIT_EXPIRATION.ago)
      .size

    return if today_invites < USER_INVITES_PER_DAY

    errors.add :base, :limited
    throw :abort
  end

  def check_club_invites_limit
    today_invites = ClubInvite
      .where(club_id: club_id)
      .where('created_at > ?', INVITES_LIMIT_EXPIRATION.ago)
      .size

    return if today_invites < CLUB_INVITES_PER_DAY

    errors.add :base, :limited
    throw :abort
  end
end
