require 'spec_helper'

describe MessagesController do
  let!(:user) { create :user, email: email }

  describe :bounce do
    let(:email) { 'test@gmail.com' }
    before { post :bounce, Email: email }

    it { should respond_with 200 }
    it { user.messages.should have(1).item }
  end
end
