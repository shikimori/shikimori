require 'spec_helper'

describe ProfilesController do
  let!(:user) { create :user }

  describe :show do
    before { get :show, id: user.to_param }
    it { should respond_with :success }
  end
end
