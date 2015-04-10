# TODO: переделать на state_machine
class GroupInvite < ActiveRecord::Base
  belongs_to :group
  belongs_to :src, class_name: User.name, foreign_key: :src_id
  belongs_to :dst, class_name: User.name, foreign_key: :dst_id
  # сообщение о приглашении
  belongs_to :message, dependent: :destroy

  validates :group, :src, :dst, presence: true
  validate :banned?, :invited?, :joined?, if: :dst

  after_create :create_message
  after_create :cleanup_invites

  def accept!
    update_column :status, GroupInviteStatus::Accepted
    message.update read: true
    group.join dst
  end

  def reject!
    update_column :status, GroupInviteStatus::Rejected
    message.update read: true
  end

private
  def create_message
    message = Message.create!(
      kind: MessageType::GroupRequest,
      from: src,
      to: dst,
      linked: group,
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

  def banned?
    errors.add :base, :banned if group.banned? dst
  end

  def invited?
    errors.add :base, :invited if group.invited? dst
  end

  def joined?
    errors.add :base, :joined if group.joined? dst
  end
end
