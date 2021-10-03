describe MessagesController do
  include_context :authenticated
  let(:user) { user_3 }

  describe '#index' do
    subject! { get :index, params: { profile_id: user.to_param, messages_type: 'notifications' } }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :show, params: { id: message.id } }

    context 'has access' do
      subject! { make_request }
      it do
        expect(response).to render_template :show
        expect(response).to have_http_status :success
      end
    end

    context 'no access' do
      let(:message) { create :message }
      it do
        expect(response).to_not render_template :show
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#tooltip' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :tooltip, params: { id: message.to_param } }

    context 'has access' do
      subject! { make_request }
      it do
        expect(response).to render_template :show
        expect(response).to have_http_status :success
      end
    end

    context 'no access' do
      let(:message) { create :message }
      it do
        expect(response).to_not render_template :show
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#edit' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :edit, params: { id: message.id } }

    context 'has access' do
      subject! { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#chosen' do
    let!(:message_1) { create :message, to: user, from: user_2, created_at: 1.hour.ago }
    let!(:message_2) { create :message, to: user_2, from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user_2, from: build_stubbed(:user) }

    subject! { get :chosen, params: { ids: [message_1.id, message_2.id, message_3.id].join(',') } }

    it do
      expect(response).to have_http_status :success
      expect(collection).to eq [message_1, message_2]
    end
  end

  describe '#unsubscribe' do
    let(:user) do
      create :user,
        notification_settings: [Types::User::NotificationSettings[:private_message_email]]
    end
    let(:make_request) do
      get :unsubscribe,
        params: {
          name: user.nickname,
          kind: MessageType::PRIVATE,
          key: key
        }
    end

    before { sign_out user }

    context 'valid key' do
      subject! { make_request }
      let(:key) { MessagesController.unsubscribe_key user, MessageType::PRIVATE }

      it do
        expect(response).to have_http_status :success
        expect(User.find(user.id).notification_settings).to be_empty
      end
    end

    context 'invalid key' do
      let(:key) { 'asd' }
      it do
        expect { make_request }.to raise_error CanCan::AccessDenied
        expect(User.find(user.id).notification_settings).to_not be_empty
      end
    end
  end
end
