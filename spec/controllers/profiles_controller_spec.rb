require 'spec_helper'

describe ProfilesController do
  let!(:user) { create :user }

  describe :show do
    before { get :show, id: user.to_param }
    it { should respond_with :success }
  end

  describe :friends do
    before { get :friends, id: user.to_param }
    it { should respond_with :success }
  end

  describe :clubs do
    before { get :clubs, id: user.to_param }
    it { should respond_with :success }
  end

  describe :favourites do
    before { get :favourites, id: user.to_param }
    it { should respond_with :success }
  end

  describe :history do
    before { get :history, id: user.to_param }
    it { should respond_with :success }
  end

  describe :stats do
    before { get :stats, id: user.to_param }
    it { should respond_with :success }
  end
end
