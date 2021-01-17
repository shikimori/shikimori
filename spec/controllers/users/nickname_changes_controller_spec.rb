describe Users::NicknameChangesController do
  describe '#index' do
    let!(:nickname_change) { create :user_nickname_change, user: user }
    subject! { get :index, params: { profile_id: user.to_param } }

    it do
      expect(collection).to eq [nickname_change]
      expect(response).to have_http_status :success
    end
  end
end
