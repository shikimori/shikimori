describe UserPreferencesController, :type => :controller do
  let(:user) { create :user, :preferences }

  describe '#update' do
    let(:make_request) { patch :update, id: user.to_param, page: 'profile', user: user_params, user_preferences: preferences_params }
    let(:user_params) { nil }
    let(:preferences_params) {{ body_background: 'test2' }}

    context 'when invalid access' do
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end

    context 'when valid access' do
      before { sign_in user }
      before { make_request }

      context 'preference change' do
        it { expect(resource.preferences.body_background).to eq preferences_params[:body_background] }
        it { should redirect_to edit_profile_url(user, page: :profile) }
      end

      context 'user changes' do
        let(:user_params) {{ about: 'zxc' }}
        it { expect(resource.about).to eq user_params[:about] }
        it { should redirect_to edit_profile_url(user, page: :profile) }
      end
    end
  end
end
