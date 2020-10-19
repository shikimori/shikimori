describe UserTokensController do
  describe '#destroy' do
    include_context :authenticated, :user
    let(:make_request) { delete :destroy, params: { id: user_token.id } }

    context 'allowed' do
      let(:user_token) { create :user_token, user: user }
      before { make_request }

      it do
        expect { user_token.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(response).to redirect_to edit_profile_url(user, section: 'account')
      end
    end

    context 'not allowed' do
      let(:user_token) { create :user_token, user: user_2 }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
