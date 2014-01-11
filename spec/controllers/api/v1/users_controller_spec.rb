require 'spec_helper'

describe Api::V1::UsersController do
  describe :show do
    let(:user) { create :user }
    before { get :show, id: user.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
