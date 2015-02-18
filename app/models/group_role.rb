# TODO: переименовать в ClubRole
# TODO: заменить status на state_machine
class GroupRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :group, counter_cache: true, touch: true

  after_create :accept_invites
  #after_create :subscribe_user

  before_destroy :destroy_invites
  #before_destroy :unsubscibe_user

  enumerize :role, in: [:member, :admin], defualt: :member, predicates: true

  validates :user, :group, :role, presence: true

private
  def accept_invites
    GroupInvite.where(dst_id: user_id, group_id: group_id).each do |v|
      v.update_columns status: GroupInviteStatus::Accepted
      v.message.update! read: true if v.message
    end
  end

  def destroy_invites
    GroupInvite.where(dst_id: user_id, group_id: group_id).destroy_all
  end

  #def subscribe_user
    #user.subscribe group.thread
  #end

  #def unsubscibe_user
    #user.unsubscribe group.thread
  #end
end
