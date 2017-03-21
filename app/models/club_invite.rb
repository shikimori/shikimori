class ClubInvite < ApplicationRecord
  belongs_to :club
  belongs_to :src, class_name: User.name, foreign_key: :src_id
  belongs_to :dst, class_name: User.name, foreign_key: :dst_id
  # сообщение о приглашении
  belongs_to :message, dependent: :destroy

  enumerize :status,
    in: Types::ClubInvite::Status.values,
    predicates: true,
    default: Types::ClubInvite::Status[:pending]

  validates :club, :src, :dst, presence: true
  validates :dst_id, uniqueness: {
    scope: [:club_id, :status],
    message: ->(key, _model) { I18n.t key }
  }

  before_create :check_banned
  before_create :check_joined

  after_create :create_message
  before_create :cleanup_invites

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
      kind: MessageType::ClubRequest,
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
end
