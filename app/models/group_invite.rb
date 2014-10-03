# TODO: переделать на state_machine
class GroupInvite < ActiveRecord::Base
  belongs_to :group
  belongs_to :src, class_name: User.name, foreign_key: :src_id
  belongs_to :dst, class_name: User.name, foreign_key: :dst_id
  # сообщение о приглашении
  belongs_to :message, dependent: :destroy

  validates :group, :src, :dst, presence: true
  validate :cannot_be_banned, :cannot_be_invited, :cannot_be_joined, if: :dst

  after_create :create_message
  after_create :cleanup_invites

  def accept!
    update status: GroupInviteStatus::Accepted
    group.join dst
  end

  def reject!
    update status: GroupInviteStatus::Rejected
  end

private
  def create_message
    message = Message.create!(
      kind: MessageType::GroupRequest,
      from: src,
      to: dst,
      subject: id,
      body: "Приглашение на вступление в клуб [group]#{group_id}[/group]."
    )

    update message: message
  end

  def cleanup_invites
    GroupInvite
      .where(dst_id: dst_id, group_id: group_id)
      .where.not(id: id)
      .destroy_all
  end

  def cannot_be_banned
    errors.add :base, :banned if group.banned? dst
  end

  def cannot_be_invited
    errors.add :base, :invited if group.invited? dst
  end

  def cannot_be_joined
    errors.add :base, :joined if group.joined? dst
  end
end
