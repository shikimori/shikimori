# describe 'Authentication', type: :request do
#   let(:json) { JSON.parse response.body }

#   describe 'POST /oauth/token' do
#     describe 'grant_type password' do
#       let(:user) { create :user, email: 'user@example.com', password: '12345678' }

#       context 'with valid params' do
#         before do
#           post '/oauth/token',
#             params: {
#               grant_type: 'password',
#               username: user.email,
#               password: '12345678'
#             }
#         end

#         it 'returns token' do
#           expect(json['error']).to eq 'unsupported_grant_type'
#           expect(Doorkeeper::AccessToken.count).to eq 0
#           expect(response.status).to eq 401
#         end
#       end
#     end

#     describe 'grant_type client_credentials' do
#       context 'with valid params' do
#         let(:client_application) { create :client_application }

#         before do
#           post '/oauth/token',
#             params: {
#               grant_type: 'client_credentials',
#               client_id: client_application.uid,
#               client_secret: client_application.secret
#             }
#         end

#         it 'returns token' do
#           expect(Doorkeeper::AccessToken.count).to eq 1
#           expect(Doorkeeper::AccessToken.first.application_id).to eq client_application.id

#           expect(json['access_token'].size).to eq 64
#           expect(json['refresh_token']).to eq nil
#           expect(json['token_type']).to eq 'bearer'
#           expect(json['expires_in']).to eq 7200
#           expect(json['created_at'].present?).to eq true
#           expect(response.status).to eq 200
#         end
#       end
#     end

#     # describe 'grant_type authorization_code' do
#       # context 'with valid params' do
#       #   let(:client_application) { create :client_application }

#       #   before do
#       #     post '/oauth/token',
#       #       params: {
#       #         grant_type: 'client_credentials',
#       #         client_id: client_application.uid,
#       #         client_secret: client_application.secret
#       #       }
#       #   end

#       #   it 'returns token' do
#       #     expect(Doorkeeper::AccessToken.count).to eq 1
#       #     expect(Doorkeeper::AccessToken.first.application_id).to eq client_application.id

#       #     expect(json['access_token'].size).to eq 64
#       #     expect(json['refresh_token']).to eq nil
#       #     expect(json['token_type']).to eq 'bearer'
#       #     expect(json['expires_in']).to eq 7200
#       #     expect(json['created_at'].present?).to eq true
#       #     expect(response.status).to eq 200
#       #   end
#       # end
#     # end

#     describe 'grant_type refresh_token' do
#       let(:user) { create :user, email: 'user@example.com', password: '12345678' }
#       let(:client_application) { create :client_application }
#       let(:refresh_token) do
#         client_application
#           .access_tokens
#           .create!(
#             use_refresh_token: true,
#             resource_owner_id: user.id
#           )
#           .refresh_token
#       end

#       before do
#         post '/oauth/token',
#           params: {
#             grant_type: 'refresh_token',
#             refresh_token: refresh_token,
#             client_id: client_application.uid,
#             client_secret: client_application.secret
#           }
#       end

#       it 'returns new refresh_token' do
#         expect(Doorkeeper::AccessToken.count).to eq 2
#         expect(Doorkeeper::AccessToken.second.application_id).to eq client_application.id

#         expect(json['access_token'].size).to eq 64
#         expect(json['refresh_token'].size).to eq 64
#         expect(json['refresh_token'].size).to_not eq refresh_token
#         expect(json['token_type']).to eq 'bearer'
#         expect(json['expires_in']).to eq 7200
#         expect(json['created_at'].present?).to eq true
#         expect(response.status).to eq 200
#       end
#     end
#   end
# end
