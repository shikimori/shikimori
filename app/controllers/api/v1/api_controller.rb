class Api::V1::ApiController < ShikimoriController
  responders :json # для рендеринга контента на patch и put запросы
  before_action :authenticate_user_from_token!
  skip_before_action :verify_authenticity_token, if: -> { @authenticated_by_token }

  resource_description do
    api_version '1'
  end

private
  def authenticate_user_from_token!
    user_nickname = request.headers['X-User-Nickname']
    user_token = request.headers['X-User-Api-Access-Token']

    user = user_nickname && user_token && User.find_by(nickname: user_nickname)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.api_access_token, user_token)
      sign_in user, store: false
      @authenticated_by_token = true
    end
  end
end
