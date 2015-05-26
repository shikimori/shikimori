describe Api::V1::DialogsController, :show_in_doc do
  describe '#index' do
    include_context :authenticated, :user
    let!(:message) { create :message, from: user, to: create(:user) }
    before { get :index, page: 1, limit: Api::V1::DialogsController::MESSAGES_PER_PAGE, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    include_context :authenticated, :user
    let(:target_user) { create :user }
    let!(:message_1) { create :message, from: user, to: target_user }
    let!(:message_2) { create :message, from: target_user, to: user }

    before { get :show, id: target_user.to_param, page: 1, limit: Api::V1::DialogsController::MESSAGES_PER_PAGE, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#destroy' do
    include_context :authenticated, :user
    let(:target_user) { create :user }
    let!(:message) { create :message, from: user, to: target_user }

    before { delete :destroy, id: target_user.to_param }

    it do
      expect(response.content_type).to eq 'application/json'
      expect(message.reload.is_deleted_by_from).to eq true
      expect(response).to have_http_status :success
    end
  end
end
