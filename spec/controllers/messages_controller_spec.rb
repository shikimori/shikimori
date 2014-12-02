describe MessagesController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index, profile_id: user.to_param, messages_type: 'notifications' }
    it { should respond_with :success }
  end

  describe '#bounce' do
    let(:user) { create :user }
    before { sign_out user }
    before { post :bounce, Email: user.email }

    it { should respond_with :success }
    it { expect(user.messages.size).to eq(1) }
  end

  describe '#show' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :show, id: message.id }

    context 'has access' do
      before { make_request }
      it { should respond_with :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  #describe '#show', :focus do
    #let(:message) { create :message, from: user }
    #let(:make_request) { get :show, id: message.id }

    #context 'has access' do
      #before { make_request }

      #context 'html' do
        #it { should respond_with :success }
        #it { expect(response.content_type).to eq 'text/html' }
      #end

      #context 'json' do
        #let(:make_request) { get :show, id: message.id, format: :json }
        #it { should respond_with :success }
        #it { expect(response.content_type).to eq 'application/json' }
      #end
    #end

    #context 'no access' do
      #let(:message) { create :message }
      #it { expect{make_request}.to raise_error CanCan::AccessDenied }
    #end
  #end

  describe '#edit' do
    let(:message) { create :message, from: user }
    let(:make_request) { get :edit, id: message.id }

    context 'has access' do
      before { make_request }
      it { should respond_with :success }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#preview' do
    let(:user) { create :user }
    before { post :preview, message: { body: 'test', from_id: user.id, to_id: user.id, kind: MessageType::Private } }

    it { should respond_with :success }
  end

  describe '#update' do
    let(:message) { create :message, from: user }
    let(:params) {{ body: 'werdfghj' }}
    let(:make_request) { patch :update, id: message.id, message: params, format: :json }

    context 'has access' do
      before { make_request }

      context 'valid params' do
        it { should respond_with :success }
        it { expect(response.content_type).to eq 'application/json' }
        it { expect(resource).to have_attributes params }
      end

      context 'invalid params' do
        let(:params) {{ body: '' }}
        it { should respond_with 422 }
      end
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#create' do
    let(:target_user) { create :user }
    let(:kind) { MessageType::Private }
    let(:params) {{ from_id: user.id, to_id: target_user.id, body: body, kind: kind }}
    let(:body) { 'werdfghj' }
    let(:make_request) { post :create, message: params, format: :json }

    context 'has access' do
      before { make_request }

      context 'valid params' do
        it { should respond_with :success }
        it { expect(response.content_type).to eq 'application/json' }
        it { expect(resource).to have_attributes params }
      end

      context 'invalid params' do
        let(:body) { '' }
        it { should respond_with 422 }
      end
    end

    context 'no access' do
      let(:kind) { MessageType::Notification }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#destroy' do
    let(:message) { create :message, :private, from: user }
    let(:make_request) { delete :destroy, id: message.id }

    context 'has access' do
      before { make_request }
      it { should respond_with :success }
      it { expect(response.content_type).to eq 'application/json' }
      it { expect(resource).to be_destroyed }
    end

    context 'no access' do
      let(:message) { create :message }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end

  describe '#mark_read' do
    let(:message_from) { create :message, from: user }
    let(:message_to) { create :message, to: user }
    before { post :mark_read, ids: "message-#{message_to.id},message-#{message_from.id},message-987654" }

    it { should respond_with :success }
    it { expect(message_from.reload.read).to be_falsy }
    it { expect(message_to.reload.read).to be_truthy }
  end

  describe '#read_all' do
    let!(:message_1) { create :message, :news, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }
    before { post :read_all, profile_id: user.to_param, messages_type: 'news' }

    it { should redirect_to index_profile_messages_url(user.to_param, 'news') }
    it { expect(message_1.reload).to be_read }
    it { expect(message_2.reload).to_not be_read }
    it { expect(message_3.reload).to_not be_read }
  end

  describe '#delete_all' do
    let!(:message_1) { create :message, :profile_commented, to: user, from: user, created_at: 1.hour.ago }
    let!(:message_2) { create :message, :profile_commented, to: create(:user), from: user, created_at: 30.minutes.ago }
    let!(:message_3) { create :message, :private, to: user, from: user }
    before { post :delete_all, profile_id: user.to_param, messages_type: 'notifications' }

    it { should redirect_to index_profile_messages_url(user.to_param, 'notifications') }
    it { expect{message_1.reload}.to raise_error ActiveRecord::RecordNotFound }
    it { expect(message_2.reload).to be_persisted }
    it { expect(message_3.reload).to be_persisted }
  end
end
