describe Api::V1::AccessTokensController, :show_in_doc do
  let(:token) { 'XXXXXXXXXXXXXXXXXXXX' }
  let(:nickname) { 'user_nickname' }
  let(:password) { 'user_password' }
  let!(:user) { create :user, nickname: nickname, password: password, api_access_token: token }

  describe '#show' do
    before { get :show, nickname: nickname, password: password }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(JSON.parse(response.body)).to eq 'api_access_token' => token
    end
  end

  describe '#create' do
    before { post :create, nickname: nickname, password: password }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(JSON.parse(response.body)).to eq 'api_access_token' => token
    end
  end
end
