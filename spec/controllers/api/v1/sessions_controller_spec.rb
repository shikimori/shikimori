describe Api::V1::SessionsController do
  describe 'create' do
    let!(:user) { create :user, nickname: 'test', password: '123456' }
    before { @request.env["devise.mapping"] = Devise.mappings[:user] }
    before { post :create, user: { nickname: user.nickname, password: '123456' }, format: :json }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
