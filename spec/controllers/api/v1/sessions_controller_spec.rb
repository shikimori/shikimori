describe Api::V1::SessionsController, :show_in_doc do
  describe '#create' do
    let!(:user) { create :user, nickname: 'test', password: '123456' }
    before { @request.env["devise.mapping"] = Devise.mappings[:user] }
    before { post :create, user: { nickname: user.nickname, password: '123456' }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
