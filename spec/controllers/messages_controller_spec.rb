describe MessagesController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index, profile_id: user.to_param, messages_type: 'notifications' }
    it { expect(response).to have_http_status :success }
  end

  describe '#bounce' do
    let(:user) { create :user }
    before { sign_out user }
    before { post :bounce, mandrill_events: [{msg: {email: user.email}}].to_json }

    it do
      expect(response).to have_http_status :success
      expect(user.messages.size).to eq(1)
    end
  end

  describe '#show' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :show, id: message.id }

    context 'has access' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#edit' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :edit, id: message.id }

    context 'has access' do
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#preview' do
    let(:user) { create :user }
    before { post :preview, message: { body: 'test', from_id: user.id, to_id: user.id, kind: MessageType::Private } }

    it { expect(response).to have_http_status :success }
  end

  describe '#chosen' do
    let(:target_user) { create :user }
    let!(:message_1) { create :message, to: user, from: target_user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, to: target_user, from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: target_user, from: build_stubbed(:user) }

    before { get :chosen, ids: [message_1.id, message_2.id, message_3.id].join(',') }

    it do
      expect(response).to have_http_status :success
      expect(collection).to eq [message_1, message_2]
    end
  end

  describe '#unsubscribe' do
    let(:user) { create :user, notifications: User::PRIVATE_MESSAGES_TO_EMAIL }
    let(:make_request) { get :unsubscribe, name: user.nickname, kind: MessageType::Private, key: key }

    before { sign_out user }

    context 'valid key' do
      before { make_request }
      let(:key) { MessagesController.unsubscribe_key(user, MessageType::Private) }

      it do
        expect(response).to have_http_status :success
        expect(user.reload.notifications).to be_zero
      end
    end

    context 'invalid key' do
      let(:key) { 'asd' }
      it do
        expect{make_request}.to raise_error CanCan::AccessDenied
        expect(user.reload.notifications).to eq User::PRIVATE_MESSAGES_TO_EMAIL
      end
    end
  end
end
