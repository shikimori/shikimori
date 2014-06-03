class GroupRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :group, counter_cache: true, touch: true

  after_create :accept_invite
  after_create :subscribe_user

  before_destroy :destroy_invite
  before_destroy :unsubscibe_user

  Member = 'member'
  Admin = 'admin'
  Moderator = 'moderator'

private
  def accept_invite
    GroupInvite.where(dst_id: user_id, group_id: group_id).each do |v|
      v.update_attribute(:status, GroupInviteStatus::Accepted)
      v.message.update_attribute(:read, true)
    end
  end

  def destroy_invite
    GroupInvite.where(dst_id: user_id, group_id: group_id).destroy_all
  end

  def subscribe_user
    user.subscribe group.thread
  end

  def unsubscibe_user
    user.unsubscribe group.thread
  end
end
