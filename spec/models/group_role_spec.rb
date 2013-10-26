
require 'spec_helper'

describe GroupRole do
  let (:group) { create :group }
  let (:user) { create :user }
  let (:user2) { create :user }

  it 'uniq index on user_id+group_id should work' do
    expect {
      lambda {
        group.members << user
        group.members << user
      }.should raise_error(ActiveRecord::RecordNotUnique)
    }.to change(GroupRole, :count).by(1)
  end

  it 'accepts pending invite after own create' do
    invite = create :group_invite, :src_id => user2.id, :dst_id => user.id, :group_id => group.id
    invite.status.should == GroupInviteStatus::Pending
    create :group_role, :group_id => group.id, :user_id => user.id
    GroupInvite.last.status.should == GroupInviteStatus::Accepted
  end

  it 'destroys invite after own create' do
    invite = create :group_invite, :src_id => user2.id, :dst_id => user.id, :group_id => group.id
    group_role = create :group_role, :group_id => group.id, :user_id => user.id
    expect {
      group_role.destroy
    }.to change(GroupInvite, :count).by(-1)
  end

  it 'subscribes user to group' do
    expect {
      group.members << user
    }.to change(Subscription, :count).by(1)

    user.subscribed?(group.thread).should be_true
  end

  it 'unsubscribes user from group' do
    group.members << user

    expect {
      group.member_roles.where(user_id: user.id).first.destroy
    }.to change(Subscription, :count).by(-1)

    user.reload
    user.subscribed?(group.thread).should be_false
  end
end
