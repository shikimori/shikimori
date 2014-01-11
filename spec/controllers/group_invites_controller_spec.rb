require 'spec_helper'

describe GroupInvitesController do
  let(:user) { create :user }
  before { sign_in user }

  describe Group do
    describe 'with Free join_policy' do
      let(:group) { create :group, join_policy: GroupJoinPolicy::Free }
      let(:user2) { create :user }

      it "can create invites from members" do
        group.members << user
        expect {
          post :create, group_id: group.id, nickname: user2.nickname
          response.should be_succes
        }.to change(GroupInvite, :count).by(1)
        invite = GroupInvite.last
        invite.group_id.should be(group.id)
        invite.src_id.should be(user.id)
        invite.dst_id.should be(user2.id)
        invite.status.should eq GroupInviteStatus::Pending
      end

      it "can create invites from signed out users" do
        sign_out user
        group.members << user
        expect {
          post :create, group_id: group.id, nickname: user2.nickname
          response.should_not be_succes
        }.to change(GroupInvite, :count).by(0)
      end

      it "can't create invites from random people" do
        expect {
          post :create, group_id: group.id, nickname: user2.nickname
          response.should_not be_succes
        }.to change(GroupInvite, :count).by(0)
      end

      it "can't create invites to the same group members" do
        group.members << user
        group.members << user2
        expect {
          post :create, group_id: group.id, nickname: user2.nickname
          response.should_not be_succes
        }.to change(GroupInvite, :count).by(0)
      end

      it "can't create invites to one user twice" do
        group.members << user
        expect {
          post :create, group_id: group.id, nickname: user2.nickname
          response.should be_succes
          post :create, group_id: group.id, nickname: user2.nickname
          response.should_not be_succes
        }.to change(GroupInvite, :count).by(1)
      end

      it "can't create invites to never existed users" do
        group.members << user
        expect {
          post :create, group_id: group.id, nickname: ''
          response.should_not be_succes
        }.to change(GroupInvite, :count).by(0)
      end
    end
  end

  describe GroupInvite do
    let(:group) { create :group }
    let(:user) { create :user }
    let(:invite) { create :group_invite, status: GroupInviteStatus::Pending, src_id: user.id, dst_id: user.id, group_id: group.id }

    it 'accepts invite' do
      put :accept, id: invite.id
      response.should be_succes

      GroupInvite.last.status.should eq GroupInviteStatus::Accepted
      group.members.should include(user)
    end

    it 'rejects invite' do
      put :reject, id: invite.id
      response.should be_succes

      GroupInvite.last.status.should eq GroupInviteStatus::Rejected
      group.members.should_not include(user)
    end

    it 'does not raise errors for not Pending invite' do
      invite.update_attribute(:status, GroupInviteStatus::Rejected)

      put :accept, id: invite.id
      response.should be_succes

      put :accept, id: invite.id
      response.should be_succes

      invite.reload.status.should eq GroupInviteStatus::Rejected
    end

    it "doesn't accept another people invites" do
      user2 = create :user
      sign_in user2

      put :accept, id: invite.id
      response.should_not be_succes

      GroupInvite.last.status.should eq GroupInviteStatus::Pending
      group.members.should_not include(user2)
    end
  end
end
