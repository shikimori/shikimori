describe MessagesController do
  describe '#index' do
    include_context :authenticated, :user
    before { get :index, profile_id: user.to_param, messages_type: 'notifications' }
    it { should respond_with :success }
  end

  describe '#bounce' do
    let(:user) { create :user }
    before { post :bounce, Email: user.email }

    it { should respond_with :success }
    it { expect(user.messages.size).to eq(1) }
  end

  describe '#destroy' do
    include_context :authenticated, :user
    let(:message) { create :message, to: user }

    before { delete :destroy, profile_id: user.to_param, id: message.id }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
    it { expect(message.reload.dst_del).to be_truthy }
  end
end
