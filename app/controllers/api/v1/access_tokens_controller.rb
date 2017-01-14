class Api::V1::AccessTokensController < Api::V1Controller
  skip_before_action :verify_authenticity_token

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/access_token', 'Get an access token by GET'
  def show
    user = User.find_by nickname: params[:nickname]

    if user && user.valid_password?(params[:password])
      render json: { api_access_token: user.api_access_token }
    else
      render json: { api_access_token: nil }
    end
  end

  api :POST, '/access_token', 'Get an access token by POST'
  param :nickname, String, required: true
  param :password, String, required: true
  def create
    user = User.find_by nickname: params[:nickname]

    if user && user.valid_password?(params[:password])
      render json: { api_access_token: user.api_access_token }
    else
      render json: { api_access_token: nil }
    end
  end
end
