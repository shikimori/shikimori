describe DialogsController do
  describe '#index' do
    include_context :authenticated, :user
    let!(:message) { create :message, from: user, to: create(:user) }
    before { get :index, params: { profile_id: user.to_param } }

    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    include_context :authenticated, :user
    let(:target_user) { create :user }
    let!(:message_1) { create :message, from: user, to: target_user }
    let!(:message_2) { create :message, from: target_user, to: user }

    before { get :show, params: { profile_id: user.to_param, id: target_user.to_param } }

    it { expect(response).to have_http_status :success }
  end

  describe '#destroy' do
    include_context :authenticated, :user
    let(:target_user) { create :user }
    let(:message) { create :message, from: user, to: target_user }

    before { delete :destroy, params: { profile_id: user.to_param, id: message } }

    it do
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect { message.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to have_http_status :success
    end
  end
end
