describe UserTokensController do
  describe '#destroy' do
    include_context :authenticated, :user
    let(:make_request) { delete :destroy, id: user_token.id }

    context 'allowed' do
      let(:user_token) { create :user_token, user: user }
      before { make_request }
      it { expect(response).to redirect_to edit_profile_url(user) }
      it { expect{user_token.reload}.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'not allowed' do
      let(:user_token) { create :user_token }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end
  end
end
