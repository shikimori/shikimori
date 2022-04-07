describe Api::V1::MessagesController do
  include_context :authenticated
  let(:user) { create :user, :day_registered, nickname: 'zxc' } # do not remove. for apipie specs there is additional Timecop.freeze

  describe '#show' do
    let(:make_request) { get :show, params: { id: message.id }, format: :json }

    describe 'has access', :show_in_doc do
      subject! { make_request }
      let(:message) { create :message, from: user }
      it { expect(response).to have_http_status :success }
    end

    describe 'no access' do
      let(:message) { create :message, from: user_1, to: user_1 }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#create' do
    subject! do
      post :create,
        params: {
          frontend: is_frontend,
          message: params
        },
        format: :json
    end
    let(:params) do
      {
        kind: MessageType::PRIVATE,
        from_id: user.id,
        to_id: to_id,
        body: body
      }
    end
    let(:to_id) { user.id }
    let(:body) { 'xx' }

    context 'success' do
      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :successful_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :successful_resource_change, :api
      end
    end

    context 'failure' do
      let(:to_id) { 0 }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failed_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failed_resource_change
      end
    end
  end

  describe '#update' do
    subject! do
      patch :update,
        params: {
          id: message.id,
          frontend: is_frontend,
          message: params
        },
        format: :json
    end
    let(:message) { create :message, :private, from: user, to: user }
    let(:params) { { body: body } }

    context 'success' do
      let(:body) { 'blablabla' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :successful_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :successful_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failed_resource_change, true
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failed_resource_change, true
      end
    end
  end

  describe '#destroy', :show_in_doc do
    let(:message) { create :message, :notification, from: user, to: user }
    subject! { delete :destroy, params: { id: message.id }, format: :json }

    it do
      expect(resource).to be_destroyed
      expect(response).to have_http_status :success
    end
  end

  describe '#mark_read', :show_in_doc do
    let(:message_from) { create :message, from: user }
    let(:message_to) { create :message, to: user }
    subject! do
      post :mark_read, params: {
        is_read: '1',
        ids: [message_to.id, message_from.id, 987_654].join(',')
      }
    end

    it do
      expect(message_from.reload.read).to eq false
      expect(message_to.reload.read).to eq true
      expect(response).to have_http_status :success
    end
  end

  describe '#read_all' do
    let!(:message_1) do
      create :message, :news,
        to: user,
        from: user,
        created_at: 1.hour.ago
    end
    let!(:message_2) do
      create :message, :profile_commented,
        to: user_1,
        from: user,
        created_at: 30.minutes.ago
    end
    let!(:message_3) { create :message, :private, to: user, from: user }

    include_context :back_redirect
    subject! { post :read_all, params: { type: 'news', frontend: is_frontend } }

    context 'api', :show_in_doc do
      let(:is_frontend) { false }
      it do
        expect(message_1.reload).to be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to_not be_read
        expect(response).to have_http_status :success
      end
    end

    context 'frontend' do
      let(:is_frontend) { true }

      it do
        expect(message_1.reload).to be_read
        expect(message_2.reload).to_not be_read
        expect(message_3.reload).to_not be_read
        expect(response).to redirect_to back_url
      end
    end
  end

  describe '#delete_all' do
    let!(:message_1) do
      create :message, :profile_commented,
        to: user,
        from: user,
        created_at: 1.hour.ago
    end
    let!(:message_2) do
      create :message, :profile_commented,
        to: user_1,
        from: user,
        created_at: 30.minutes.ago
    end
    let!(:message_3) { create :message, :private, to: user, from: user }

    include_context :back_redirect
    subject! do
      post :delete_all,
        params: {
          type: 'notifications',
          frontend: is_frontend
        }
    end

    context 'api', :show_in_doc do
      let(:is_frontend) { false }
      it do
        expect { message_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
        expect(response).to have_http_status :success
      end
    end

    context 'frontend' do
      let(:is_frontend) { true }

      it do
        expect { message_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
        expect(response).to redirect_to back_url
      end
    end
  end
end
