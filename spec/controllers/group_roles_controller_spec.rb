require 'spec_helper'

describe GroupRolesController do
  #before (:each) do
    #@user = create :user
    #sign_in @user
  #end
  let(:club) { create :group }

  describe '#create' do
    include_context :authenticated
    before { post :create, club_id: club.id, group_role: { group_id: club.id, user_id: user.id } }

    it { should redirect_to club_url(club) }
    it { expect(club.has_member? user).to be true }
  end

  describe '#destroy' do
    include_context :authenticated
    let!(:group_role) { create :group_role, group: club, user: user }
    before { post :destroy, club_id: club.id, id: group_role.id }

    it { should redirect_to club_url(club) }
    it { expect(club.has_member? user).to be false }
  end

  #describe Group do
    #describe 'with Free join_policy' do
      #let (:group) { create :group, :free_join }

      #it 'joins group successfully' do
        #expect {
          #post :create, id: group.id
          #response.should be_succes
        #}.to change(GroupRole, :count).by(1)
        #group.members.include?(@user).should be(true)
      #end

      #it 'accepts Pending invite when joins group' do
        #invite = create :group_invite, src: @user, dst: @user, group: group
        #post :create, id: group.id
        #GroupInvite.last.status.should == GroupInviteStatus::Accepted
      #end

      #it 'joins group only once' do
        #expect {
          #post :create, id: group.id
          #response.should be_succes

          #post :create, id: group.id
          #response.should be_succes
          #response.body.should eq "{}"
        #}.to change(GroupRole, :count).by(1)
        #group.members.include?(@user).should be_true
      #end

      #it 'leaves group successfully' do
        #group.members << @user
        #expect {
          #delete :destroy, id: group.id
          #response.should be_succes
        #}.to change(GroupRole, :count).by(-1)
        #group.members.include?(@user).should be_false
      #end

      #it 'destroys all invites when leaves group' do
        #create :group_invite, src: @user, dst: @user, group: group
        #expect {
          #group.members << @user
          #delete :destroy, id: group.id
        #}.to change(GroupInvite, :count).by(-1)
      #end
    #end
  #end

  #describe User do
    #let (:group) { create :group, owner: @user }
    #it 'becames admin when joins its own group' do
      #expect {
        #post :create, id: group.id
        #response.should be_succes
      #}.to change(GroupRole, :count).by(1)
      #group.admins.include?(@user).should be_true
    #end
  #end
end
