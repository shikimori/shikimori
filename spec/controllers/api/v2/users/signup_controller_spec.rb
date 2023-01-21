# describe Api::V2::Users::SignupController do
#   describe '#create' do
#     before do
#       allow_any_instance_of(User).to receive :grab_avatar
#       allow_any_instance_of(User).to receive :add_to_index
#     end
#
#     before do
#       if access_token
#         request.headers['Authorization'] = 'Bearer ' + access_token
#       end
#
#       post :create,
#         params: {
#           user: {
#             email: email,
#             password: password,
#             nickname: nickname
#           }
#         }
#     end
#     let(:email) { 'test@test-zxc.test' }
#     let(:nickname) { 'zxcdsfgf' }
#     let(:password) { '123' }
#
#     let(:oauth_application) { create :oauth_application }
#     let(:oauth_token) { create :oauth_token, application: oauth_application }
#     let(:access_token) { oauth_token.token }
#
#     context 'valid params', :show_in_doc do
#       it do
#         expect(resource).to be_persisted
#         expect(resource).to_not be_changed
#         expect(resource).to have_attributes(
#           nickname: nickname,
#           email: email
#         )
#         expect(resource.valid_password? password).to eq true
#         expect(response).to have_http_status :created
#       end
#     end
#
#     context 'invalid params' do
#       let(:email) { seed(:user).email }
#       it do
#         expect(resource).to_not be_persisted
#         expect(json).to eq(
#           errors: [
#             User.human_attribute_name(:email) + ' ' +
#               I18n.t('activerecord.errors.messages.taken')
#           ]
#         )
#         expect(response).to have_http_status 422
#       end
#     end
#
#     context 'user access_token' do
#       let(:oauth_token) do
#         create :oauth_token,
#           application: oauth_application,
#           resource_owner_id: seed(:user).id
#       end
#
#       it do
#         expect(resource).to be_nil
#         expect(json[:errors]).to eq [described_class::USER_TOKEN_ERROR_MESSAGE]
#         expect(response).to have_http_status 401
#       end
#     end
#
#     context 'invalid access_token' do
#       let(:access_token) { nil }
#       it do
#         expect(resource).to be_nil
#         expect(response).to have_http_status 401
#       end
#     end
#   end
# end
