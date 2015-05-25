describe Api::V1::MessagesController, :show_in_doc do
  include_context :authenticated, :user

  describe '#create' do
    let(:params) {{ kind: MessageType::Private, from_id: user.id, to_id: user.id, body: 'test' }}
    before { post :create, message: params, format: :json }

    it do
      expect(resource).to be_persisted
      expect(resource).to have_attributes params
      expect(response).to have_http_status :success
    end
  end

  describe '#update' do
    let(:params) {{ body: 'test' }}
    let(:message) { create :message, :private, from: user, to: user }
    before { patch :update, id: message.id, message: params, format: :json }

    it do
      expect(resource).to be_valid
      expect(resource).to have_attributes params
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let(:message) { create :message, :notification, from: user, to: user }
    before { delete :destroy, id: message.id, format: :json }

    it do
      expect(resource).to be_destroyed
      expect(response).to have_http_status :success
    end
  end

  describe '#mark_read' do
    let(:message_from) { create :message, from: user }
    let(:message_to) { create :message, to: user }
    before { post :mark_read, is_read: '1', ids: [message_to.id, message_from.id, 987654].join(',') }

    it do
      expect(message_from.reload.read).to be_falsy
      expect(message_to.reload.read).to be_truthy
      expect(response).to have_http_status :success
    end
  end

  describe '#read_all' do
    let!(:message_1) { create :message, :news, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }
    before { post :read_all, profile_id: user.to_param, type: 'news' }

    it do
      expect(message_1.reload).to be_read
      expect(message_2.reload).to_not be_read
      expect(message_3.reload).to_not be_read
      expect(response).to have_http_status :success
    end
  end

  describe '#delete_all' do
    let!(:message_1) { create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }
    before { post :delete_all, profile_id: user.to_param, type: 'notifications' }

    it do
      expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound
      expect(message_2.reload).to be_persisted
      expect(message_3.reload).to be_persisted
      expect(response).to have_http_status :success
    end
  end
end
