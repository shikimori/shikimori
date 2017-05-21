class Api::V1Controller < ShikimoriController
  LOGIN_HEADER = 'X-User-Nickname'
  TOKEN_HEADER = 'X-User-Api-Access-Token'

  responders :json # для рендеринга контента на patch и put запросы
  respond_to :json

  before_action :authenticate_user_from_token!, if: :headers_auth?
  before_action :touch_last_online
  skip_before_action :verify_authenticity_token, if: :headers_auth?

  serialization_scope :view_context

  resource_description do
    api_version '1.0'
  end

  API_ERRORS = [
    MissingApiParameter,
    Apipie::ParamMissing,
    Apipie::ParamInvalid
  ]
  rescue_from *API_ERRORS, with: :api_error

private

  def api_error exception
    render(
      json: [exception.message],
      status: :unprocessable_entity
    )
  end

  # rubocop:disable MethodLength
  def authenticate_user_from_token!
    user_nickname = CGI.unescape request.headers[LOGIN_HEADER]
    user_token = request.headers[TOKEN_HEADER]

    user = User.find_by(nickname: user_nickname)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.api_access_token, user_token)
      sign_in user, store: false
      @authenticated_by_token = true
    else
      render(
        json: { error: 'invalid user nickname or api access token' },
        status: 403
      )
    end
  end
  # rubocop:enable MethodLength

  def frontent_request?
    params[:frontend] && params[:frontend] != 'false'
  end

  def headers_auth?
    request.headers[LOGIN_HEADER] && request.headers[TOKEN_HEADER]
  end
end
