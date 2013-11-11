require 'spec_helper'

describe Api::V1::FriendsController do
  let(:user) { create :user, friends: [create(:user)] }
  before { sign_in user }

  describe :index do
    before { get :index }
    it { should respond_with :success }
  end
end
