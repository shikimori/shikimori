describe Api::V1::DialogsController, :show_in_doc do
  describe '#index' do
    include_context :authenticated, :user
    let!(:message) { create :message, from: user, to: create(:user) }
    before { get :index, params: { page: 1, limit: Api::V1::DialogsController::MESSAGES_PER_PAGE }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    include_context :authenticated, :user
    let(:target_user) { create :user }
    let!(:message_1) { create :message, from: user, to: target_user }
    let!(:message_2) { create :message, from: target_user, to: user }

    before { get :show, params: { id: target_user.to_param, page: 1, limit: Api::V1::DialogsController::MESSAGES_PER_PAGE }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#destroy' do
    include_context :authenticated, :user

    let(:target_user) { create :user }
    let!(:message) {}

    before { delete :destroy, params: { id: target_user.to_param } }

    context 'with message' do
      let(:message) { create :message, from: user, to: target_user }

      it do
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect { message.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(response).to have_http_status :success
        expect(json[:notice]).to eq 'Переписка удалена'
      end
    end

    context 'without messages' do
      it do
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response).to have_http_status :unprocessable_entity
        expect(json).to eq ['Не найдено ни одного сообщения для удаления']
      end
    end
  end
end
