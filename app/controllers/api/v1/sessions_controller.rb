class Api::V1::SessionsController < Devise::SessionsController
  resource_description do
    api_version '1.0'
  end

  respond_to :json

  api :POST, '/sessions', 'Create a session'
  param :user, Hash do
    param :nickname, String, required: true
    param :password, String, required: true
  end
  def create
    user = warden.authenticate!(auth_options)
    sign_in resource_name, user

    render json: {
      id: user.id,
      nickname: user.nickname,
      email: user.email,
      avatar: user.avatar.url(:x32)
    }
  end
end
