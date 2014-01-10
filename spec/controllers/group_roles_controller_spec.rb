require 'spec_helper'

describe GroupRolesController do
  before (:each) do
    @user = create :user
    sign_in @user
  end

  describe Group do
    describe 'with Free join_policy' do
      let (:group) { create :group, join_policy: GroupJoinPolicy::Free }

      it 'joins group successfully' do
        expect {
          post :create, id: group.id
          response.should be_succes
        }.to change(GroupRole, :count).by(1)
        group.members.include?(@user).should be(true)
      end

      it 'accepts Pending invite when joins group' do
        invite = create :group_invite, src: @user, dst: @user, group: group
        post :create, id: group.id
        GroupInvite.last.status.should == GroupInviteStatus::Accepted
      end

      it 'joins group only once' do
        expect {
          post :create, id: group.id
          response.should be_succes

          post :create, id: group.id
          response.should be_succes
          response.body.should eq "{}"
        }.to change(GroupRole, :count).by(1)
        group.members.include?(@user).should be_true
      end

      it 'leaves group successfully' do
        group.members << @user
        expect {
          delete :destroy, id: group.id
          response.should be_succes
        }.to change(GroupRole, :count).by(-1)
        group.members.include?(@user).should be_false
      end

      it 'destroys all invites when leaves group' do
        create :group_invite, src: @user, dst: @user, group: group
        expect {
          group.members << @user
          delete :destroy, id: group.id
        }.to change(GroupInvite, :count).by(-1)
      end
    end
  end

  describe User do
    let (:group) { create :group, join_policy: GroupJoinPolicy::Free, owner: @user }
    it 'becames admin when joins its own group' do
      expect {
        post :create, id: group.id
        response.should be_succes
      }.to change(GroupRole, :count).by(1)
      group.admins.include?(@user).should be_true
    end
  end
end
