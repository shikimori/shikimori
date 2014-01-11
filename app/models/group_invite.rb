# TODO: переделать на state_machine
class GroupInvite < ActiveRecord::Base
  # группа
  belongs_to :group
  # тот, кто послал приглашение
  belongs_to :src, class_name: User.name, :foreign_key => :src_id
  # тот, кому послано приглашение
  belongs_to :dst, class_name: User.name, :foreign_key => :dst_id
  # сообщение о преглашении
  belongs_to :message, dependent: :destroy

  after_create :create_message

  # при создании инвайта автоматически создаётся связанное с ним сообщение
  def create_message
    message = Message.create!(
      kind: MessageType::GroupRequest,
      from_id: src.id,
      to_id: dst.id,
      subject: id,
      body: "Приглашение на вступление в группу [group]#{group_id}[/group]."
    )

    update_attribute(:message_id, message.id)
    GroupInvite
      .where(dst_id: dst_id, group_id: group_id)
      .where { id != my{id} }
      .destroy_all
  end
end
