
require 'spec_helper'

describe GroupsController do
  before do
    @user = create :user
    sign_in @user
  end

  describe 'index' do
    pending 'need more specs'
  end

  describe 'show' do
    pending 'need more specs'
  end

  describe 'new' do
    pending 'need more specs'
  end

  describe 'create' do
    it 'creates new group' do
      expect {
        post :apply, :id => 'new', :group => {:name => 'test'}
        response.should be_redirect
      }.to change(Group, :count).by(1)

      group = Group.last
      group.admins.should include(@user)
      group.name.should == 'test'
      group.owner_id.should be(@user.id)
      group.join_policy.should == GroupJoinPolicy::Free
    end
  end

  #raise 'need more specs for groups_controller'

  describe Group do
    let (:group) { create :group }

    it 'restricts access for guests' do
      sign_out @user
      get :settings, id: group.id
      response.should be_unauthorized
    end

    it 'restricts access for users w/o permission to edit' do
      get :settings, id: group.id
      response.should be_forbidden
    end
  end
end
