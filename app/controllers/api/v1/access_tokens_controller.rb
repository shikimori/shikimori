class Api::V1::AccessTokensController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/access_token', 'Get an access token by GET'
  def show
    user = User.find_by nickname: params[:nickname]

    if user && user.valid_password?(params[:password])
      render json: { api_access_token: user.api_access_token }
    else
      render json: { api_access_token: nil }
    end
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/access_token', 'Get an access token by POST'
  param :nickname, :undef
  param :password, :undef
  def create
    user = User.find_by nickname: params[:nickname]

    if user && user.valid_password?(params[:password])
      render json: { api_access_token: user.api_access_token }
    else
      render json: { api_access_token: nil }
    end
  end
end
