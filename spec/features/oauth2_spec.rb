feature 'Authentication', type: :request do
  let(:json) { JSON.parse response.body }
  let(:oauth_application) do
    create :oauth_application, redirect_uri: Doorkeeper.configuration.native_redirect_uri
  end
  let(:user) { create :user, email: 'user@example.com', password: '12345678' }

  feature 'Doorkeeper::AuthorizationsController' do
    context 'authorization without redirect_uri' do
      context 'guest' do
        before do
          visit '/oauth/authorize' \
            "?client_id=#{oauth_application.uid}" \
            "&redirect_uri=#{Doorkeeper.configuration.native_redirect_uri}" \
            '&response_type=code'
        end
        scenario { expect(current_path).to eq new_user_session_path }
      end

      context 'user' do
        before { sign_in user }
        before do
          visit '/oauth/authorize' \
            "?client_id=#{oauth_application.uid}" \
            "&redirect_uri=#{Doorkeeper.configuration.native_redirect_uri}" \
            '&response_type=code'
        end

        scenario 'authorize user token' do
          expect(current_path).to eq oauth_authorization_path
          find('form.authorize').submit
          expect(user.access_grants).to have(1).item
          expect(current_path).to eq '/oauth/authorize/' +
            user.access_grants.first.token
        end
      end
    end
  end

  feature 'Doorkeeper::TokensController' do
    feature 'grant_type password' do
      context 'with valid params' do
        before do
          post '/oauth/token',
            params: {
              grant_type: 'password',
              username: user.email,
              password: '12345678'
            }
        end

        scenario 'returns token' do
          expect(json['error']).to eq 'unsupported_grant_type'
          expect(Doorkeeper::AccessToken.count).to eq 0
          expect(response).to have_http_status 401
        end
      end
    end

    feature 'grant_type client_credentials' do
      context 'with valid params' do
        before do
          post '/oauth/token',
            params: {
              grant_type: 'client_credentials',
              client_id: oauth_application.uid,
              client_secret: oauth_application.secret
            }
        end

        scenario 'returns token' do
          expect(Doorkeeper::AccessToken.count).to eq 1
          expect(Doorkeeper::AccessToken.first.application_id).to eq oauth_application.id

          expect(json['access_token'].size).to eq 64
          expect(json['refresh_token']).to eq nil
          expect(json['token_type']).to eq 'Bearer'
          expect(json['expires_in']).to eq 1.day
          expect(json['created_at'].present?).to eq true
          expect(response).to have_http_status :success
        end
      end
    end

    feature 'grant_type authorization_code' do
      context 'with valid params' do
        before do
          post '/oauth/token',
            params: {
              grant_type: 'client_credentials',
              client_id: oauth_application.uid,
              client_secret: oauth_application.secret
            }
        end

        scenario 'returns token' do
          expect(Doorkeeper::AccessToken.count).to eq 1
          expect(Doorkeeper::AccessToken.first.application_id).to eq oauth_application.id

          expect(json['access_token'].size).to eq 64
          expect(json['refresh_token']).to eq nil
          expect(json['token_type']).to eq 'Bearer'
          expect(json['expires_in']).to eq 1.day
          expect(json['created_at'].present?).to eq true
          expect(response).to have_http_status :success
        end
      end
    end

    feature 'grant_type refresh_token' do
      let(:refresh_token) do
        oauth_application
          .access_tokens
          .create!(
            use_refresh_token: true,
            resource_owner_id: user.id
          )
          .refresh_token
      end

      before do
        post '/oauth/token',
          params: {
            grant_type: 'refresh_token',
            refresh_token: refresh_token,
            client_id: oauth_application.uid,
            client_secret: oauth_application.secret
          }
      end

      scenario 'returns new refresh_token' do
        expect(Doorkeeper::AccessToken.count).to eq 2
        expect(Doorkeeper::AccessToken.second.application_id).to eq oauth_application.id

        expect(json['access_token'].size).to eq 64
        expect(json['refresh_token'].size).to eq 64
        expect(json['refresh_token'].size).to_not eq refresh_token
        expect(json['token_type']).to eq 'Bearer'
        expect(json['expires_in']).to eq 1.day
        expect(json['created_at'].present?).to eq true
        expect(response).to have_http_status :success
      end
    end
  end
end
