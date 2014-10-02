# TODO: переделать на state_machine
class GroupInvite < ActiveRecord::Base
  belongs_to :group
  belongs_to :src, class_name: User.name, foreign_key: :src_id
  belongs_to :dst, class_name: User.name, foreign_key: :dst_id
  # сообщение о приглашении
  belongs_to :message, dependent: :destroy

  validates :group, :src, :dst, presence: true

  after_create :create_message

private
  # при создании инвайта автоматически создаётся связанное с ним сообщение
  def create_message
    message = Message.create!(
      kind: MessageType::GroupRequest,
      from: src,
      to: dst,
      subject: id,
      body: "Приглашение на вступление в группу [group]#{group_id}[/group]."
    )

    update(message: message)

    GroupInvite
      .where(dst_id: dst_id, group_id: group_id)
      .where.not(id: id)
      .destroy_all
  end
end
