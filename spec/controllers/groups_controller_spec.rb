require 'spec_helper'

describe GroupsController do
  let(:user) { create :user }
  before { sign_in user }

  describe 'index' do
    let(:club_1) { create :group }
    let(:club_2) { create :group }
    before do
      club_1.members << user
      club_2.members << user
    end

    context :page_1 do
      before { get :index, page: 1 }
      it { should respond_with :success }
    end

    context :page_2 do
      before { get :index, page: 2, format: :json }
      it { should respond_with :success }
    end
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
        post :create, id: 'new', group: {name: 'test'}
        response.should be_redirect
      }.to change(Group, :count).by(1)

      group = Group.last
      group.admins.should include(user)
      group.name.should == 'test'
      group.owner_id.should be(user.id)
      group.should be_free_join
    end
  end

  #raise 'need more specs for groups_controller'

  describe Group do
    let (:group) { create :group }

    it 'restricts access for guests' do
      sign_out user
      get :settings, id: group.id
      response.should be_unauthorized
    end

    it 'restricts access for users w/o permission to edit' do
      get :settings, id: group.id
      response.should be_forbidden
    end
  end
end
