require 'spec_helper'

describe ProfilesController do
  let!(:user) { create :user }

  describe '#show' do
    before { get :show, id: user.to_param }
    it { should respond_with :success }
  end

  describe '#friends' do
    context 'without friends' do
      before { get :friends, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with friends' do
      let!(:friend_link) { create :friend_link, src: user, dst: create(:user) }
      before { get :friends, id: user.to_param }
      it { should respond_with :success }
    end
  end

  describe '#clubs' do
    context 'without clubs' do
      before { get :clubs, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with clubs' do
      let!(:club_role) { create :group_role, user: user }
      before { get :clubs, id: user.to_param }
      it { should respond_with :success }
    end
  end

  describe '#favourites' do
    context 'without favourites' do
      before { get :favourites, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with favourites' do
      let!(:favourite) { create :favourite, user: user, linked: create(:anime) }
      before { get :favourites, id: user.to_param }
      it { should respond_with :success }
    end
  end

  describe '#history' do
    context 'without history' do
      before { get :history, id: user.to_param }
      it { should redirect_to profile_url(user) }
    end

    context 'with history' do
      let!(:history) { create :user_history, user: user, target: create(:anime) }
      let(:make_request) { get :history, id: user.to_param }

      context 'has access to list' do
        before { make_request }
        it { should respond_with :success }
      end

      context 'has no access to list' do
        let(:user) { create :user, preferences: create(:user_preferences, profile_privacy: :owner) }
        before { sign_out user }
        it { expect{make_request}.to raise_error CanCan::AccessDenied }
      end
    end
  end

  #describe '#stats' do
    #before { get :stats, id: user.to_param }
    #it { should respond_with :success }
  #end

  describe '#edit' do
    let(:make_request) { get :edit, id: user.to_param, page: page }

    context 'when valid access' do
      before { sign_in user }
      before { make_request }

      describe 'account' do
        let(:page) { 'account' }
        it { should respond_with :success }
      end

      #describe 'profile' do
        #let(:page) { 'profile' }
        #it { should respond_with :success }
      #end

      #describe 'password' do
        #let(:page) { 'password' }
        #it { should respond_with :success }
      #end

      #describe 'styles' do
        #let(:page) { 'styles' }
        #it { should respond_with :success }
      #end

      #describe 'list' do
        #let(:page) { 'list' }
        #it { should respond_with :success }
      #end

      #describe 'notifications' do
        #let(:page) { 'notifications' }
        #it { should respond_with :success }
      #end

      #describe 'misc' do
        #let(:page) { 'misc' }
        #it { should respond_with :success }
      #end
    end

    context 'when invalid access' do
      let(:page) { 'account' }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#update' do
    let(:make_request) { patch :update, id: user.to_param, page: 'account', user: update_params }

    context 'when valid access' do
      before { sign_in user }

      context 'when success' do
        before { make_request }
        let(:user_2) { create :user }
        let(:update_params) {{ nickname: 'morr', ignored_user_ids: [user_2.id] }}

        it { should redirect_to edit_profile_url(resource, page: 'account') }
        it { expect(resource.nickname).to eq 'morr' }
        it { expect(resource.ignores?(user_2)).to be true }
        it { expect(resource.errors).to be_empty }
      end

      context 'when validation errors' do
        let!(:user_2) { create :user }
        let(:update_params) {{ nickname: user_2.nickname }}
        before { make_request }

        it { should respond_with :success }
        it { expect(resource.errors).to_not be_empty }
      end
    end

    context 'when invalid access' do
      let(:update_params) {{ nickname: '123' }}
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end
end
