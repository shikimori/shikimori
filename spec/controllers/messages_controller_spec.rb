describe MessagesController do
  describe '#index' do
    include_context :authenticated, :user
    before { get :index, profile_id: user.to_param }
    it { should respond_with :success }
  end

  describe '#bounce' do
    let(:user) { create :user }
    before { post :bounce, Email: user.email }

    it { should respond_with :success }
    it { expect(user.messages.size).to eq(1) }
  end
end
