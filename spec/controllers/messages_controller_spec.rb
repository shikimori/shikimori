describe MessagesController do
  let!(:user) { create :user, email: email }

  describe 'bounce' do
    let(:email) { 'test@gmail.com' }
    before { post :bounce, Email: email }

    it { should respond_with 200 }
    it { expect(user.messages.size).to eq(1) }
  end
end
