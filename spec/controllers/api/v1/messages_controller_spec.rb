describe Api::V1::MessagesController, :show_in_doc do
  include_context :authenticated, :user

  describe '#show' do
    let(:make_request) { get :show, id: message.id, format: :json }

    describe 'has access' do
      before { make_request }
      let(:message) { create :message, from: user }
      it { expect(response).to have_http_status :success }
    end

    describe 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#create' do
    before { post :create, frontend: is_frontend, message: params, format: :json }
    let(:params) do
      {
        kind: MessageType::Private,
        from_id: user.id,
        to_id: user.id,
        body: body
      }
    end

    context 'success' do
      let(:body) { 'x' * Comment::MIN_SUMMARY_SIZE }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :success_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :success_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failure_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failure_resource_change
      end
    end
  end

  describe '#update' do
    let(:message) { create :message, :private, from: user, to: user }

    before { sign_in user }
    before { patch :update, id: message.id, frontend: is_frontend, message: params, format: :json }
    let(:params) {{ body: body }}

    context 'success' do
      let(:body) { 'blablabla' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :success_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :success_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failure_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failure_resource_change
      end
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

    include_context :back_redirect
    before { post :read_all, type: 'news', frontend: is_frontend }

    context 'api' do
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
    let!(:message_1) { create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }

    include_context :back_redirect
    before { post :delete_all, type: 'notifications', frontend: is_frontend }

    context 'api' do
      let(:is_frontend) { false }
      it do
        expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
        expect(response).to have_http_status :success
      end
    end

    context 'frontend' do
      let(:is_frontend) { true }

      it do
        expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound
        expect(message_2.reload).to be_persisted
        expect(message_3.reload).to be_persisted
        expect(response).to redirect_to back_url
      end
    end
  end
end
