require 'spec_helper'

describe Api::V1::Profile::MessagesController do
  let(:user) { create :user }
  before { sign_in user }

  describe :unread do
    before { get :unread }
    it { should respond_with :success }
  end
end
