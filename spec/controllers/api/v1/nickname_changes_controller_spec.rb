describe Api::V1::NicknameChangesController do
  include_context :authenticated, :user

  describe '#cleanup' do
    before { user.nickname = 'test 78yutghjbk' }
    let!(:nickname_change) { create :user_nickname_change, user: user }
    before { delete :cleanup }

    it do
      expect(user.nickname_changes).to be_empty
      expect(response).to have_http_status :success
    end
  end
end
