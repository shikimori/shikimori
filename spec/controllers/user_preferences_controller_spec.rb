describe UserPreferencesController do
  describe '#update' do
    let(:make_request) do
      patch :update,
        params: {
          profile_id: user.to_param,
          section: 'profile',
          user: user_params,
          user_preferences: preferences_params
        }
    end
    let(:user_params) { nil }
    let(:preferences_params) { { anime_in_profile: true } }

    context 'when invalid access' do
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end

    context 'when valid access' do
      before { sign_in user }

      context 'post request' do
        before { make_request }
        it do
          expect(resource.preferences.anime_in_profile).to eq preferences_params[:anime_in_profile]
          expect(response).to redirect_to user.decorate.edit_url(section: :profile)
        end
      end

      context 'xhr request' do
        before do
          put :update,
            params: {
              profile_id: user.to_param,
              user_preferences: { forums: ['vn'] }
            },
            xhr: true
        end

        it do
          expect(resource.preferences.forums).to eq ['vn']
          expect(response).to have_http_status :success
        end
      end

      context 'user changes' do
        let(:user_params) { { about: 'zxc' } }
        before { make_request }

        it do
          expect(resource.about).to eq user_params[:about]
          expect(response).to redirect_to edit_profile_url(user, section: :profile)
        end
      end

      context 'invalid change' do
        let(:preferences_params) { { body_width: 'x1201' } }
        before { make_request }

        it do
          expect(resource.preferences).to_not be_valid
          expect(response).to render_template :edit
        end
      end
    end
  end
end
