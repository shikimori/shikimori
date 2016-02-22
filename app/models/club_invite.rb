# TODO: переделать на state_machine
class ClubInvite < ActiveRecord::Base
  belongs_to :club
  belongs_to :src, class_name: User.name, foreign_key: :src_id
  belongs_to :dst, class_name: User.name, foreign_key: :dst_id
  # сообщение о приглашении
  belongs_to :message, dependent: :destroy

  validates :club, :src, :dst, presence: true
  validate :banned?, :invited?, :joined?, if: :dst

  after_create :create_message
  after_create :cleanup_invites

  def accept!
    update_column :status, ClubInviteStatus::Accepted
    message.update read: true
    club.join dst
  end

  def reject!
    update_column :status, ClubInviteStatus::Rejected
    message.update read: true
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

  def banned?
    errors.add :base, :banned if club.banned? dst
  end

  def invited?
    errors.add :base, :invited if club.invited? dst
  end

  def joined?
    errors.add :base, :joined if club.joined? dst
  end
end
