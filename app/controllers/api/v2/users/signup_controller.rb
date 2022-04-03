class Api::V2::Users::SignupController < Api::V2Controller
#   before_action :doorkeeper_authorize!
#   before_action :check_application_oauth_token
#
#   USER_TOKEN_ERROR_MESSAGE =
#     'This token belongs to a user. Must be a token of application'
#
#   api :POST, '/v2/users/signup', 'Create a user'
#   description <<~TEXT
#     OAuth2 authorization for application is required for this method.
#
#     Add header `Authorization: Bearer APPLICATION_ACCESS_TOKEN` to your request.
#
#     <br>
#
#     Application `access_token` can be retrieved from the server with this request<br>
#
#     `curl -X POST "https://shikimori.org/oauth/token" \
#       -F grant_type="client_credentials" \
#       -F client_id="CLIENT_ID" \
#       -F client_secret="CLIENT_SECRET"
#     `
#   TEXT
#   param :user, Hash do
#     param :email, String
#     param :nickname, String
#     param :password, String
#   end
#   def create
#     @resource = User.new create_params
#
#     if @resource.save
#       render(
#         json: {
#           user: {
#             id: @resource.id,
#             nickname: @resource.nickname
#           },
#           oauth_token: generate_access_token(@resource)
#         },
#         status: 201
#       )
#     else
#       render json: { errors: @resource.errors.full_messages }, status: 422
#     end
#   end
#
# private
#
#   def check_application_oauth_token
#     if doorkeeper_token.resource_owner_id.present?
#       render json: { errors: [USER_TOKEN_ERROR_MESSAGE] }, status: 401
#     end
#   end
#
#   def generate_access_token user # rubocop:disable MethodLength, AbcSize
#     access_token = Doorkeeper::AccessToken.create!(
#       application_id: doorkeeper_token.application.id,
#       resource_owner_id: user.id,
#       scopes: [],
#       expires_in: Doorkeeper.configuration.access_token_expires_in,
#       use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
#     )
#
#     Doorkeeper::AccessGrant.create!(
#       application_id: doorkeeper_token.application.id,
#       resource_owner_id: user.id,
#       expires_in: 0,
#       redirect_uri: doorkeeper_token.application.redirect_uri
#     )
#
#     {
#       access_token: access_token.token,
#       refresh_token: access_token.refresh_token,
#       token_type: 'bearer',
#       expires_in: access_token.expires_in,
#       created_at: access_token.created_at.to_i
#     }
#   end
#
#   def current_user
#     nil
#   end
#
#   def create_params
#     params.require(:user).permit(:email, :nickname, :password)
#   end
end
