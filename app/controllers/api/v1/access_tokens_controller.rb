class Api::V1::AccessTokensController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/access_token', 'Show an access token'
  def show
    user = User.find_by nickname: params[:nickname]

    if user && user.valid_password?(params[:password])
      render json: { api_access_token: user.api_access_token }
    else
      render json: { api_access_token: nil }
    end
  end
end
