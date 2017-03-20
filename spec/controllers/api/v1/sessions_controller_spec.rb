describe Api::V1::SessionsController, :show_in_doc do
  describe '#create' do
    let!(:user) { create :user, password: '123456' }
    before { @request.env['devise.mapping'] = Devise.mappings[:user] }
    before { post :create, params: { user: { nickname: user.nickname, password: '123456' } }, format: :json }

    it do
      expect(json).to eq(
        id: user.id,
        nickname: user.nickname,
        email: user.email,
        avatar: '/assets/globals/missing_avatar/x32.png'
      )
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
