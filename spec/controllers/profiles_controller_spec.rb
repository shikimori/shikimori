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
      before { get :history, id: user.to_param }
      it { should respond_with :success }
    end
  end

  #describe '#stats' do
    #before { get :stats, id: user.to_param }
    #it { should respond_with :success }
  #end
end
