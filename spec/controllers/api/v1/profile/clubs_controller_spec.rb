require 'spec_helper'

describe Api::V1::Profile::ClubsController do
  let(:user) { create :user, groups: [create(:group)] }
  before { sign_in user }

  describe :index do
    before { get :index, format: :json }
    it { should respond_with :success }
  end
end
