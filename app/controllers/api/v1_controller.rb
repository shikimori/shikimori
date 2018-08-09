class Api::V1Controller < ShikimoriController
  LOGIN_HEADER = 'X-User-Nickname'
  ID_HEADER = 'X-User-Id'
  TOKEN_HEADER = 'X-User-Api-Access-Token'
  OAUTH_HEADER = 'Authorization'

  responders :json # for content rendering on patch & put requests
  respond_to :json

  before_action :authenticate_user_from_token!, if: :headers_auth?
  before_action :touch_last_online
  skip_before_action :verify_authenticity_token, if: :headers_auth?
  skip_before_action :verify_authenticity_token,
    if: -> { doorkeeper_token.present? }

  serialization_scope :view_context

  resource_description do
    api_version '1.0'
  end

  API_ERRORS = [
    InvalidParameterError,
    MissingApiParameter,
    Apipie::ParamMissing,
    Apipie::ParamInvalid
  ]
  rescue_from(*API_ERRORS, with: :api_error)

private

  def api_error exception
    render(
      json: [exception.message],
      status: :unprocessable_entity
    )
  end

  def authenticate_user_from_token! # rubocop:disable MethodLength, AbcSize
    user_token = request.headers[TOKEN_HEADER]

    if request.headers[LOGIN_HEADER]
      user_nickname = CGI.unescape request.headers[LOGIN_HEADER]
      user = User.find_by(nickname: user_nickname)
    elsif request.headers[ID_HEADER]
      user_id = request.headers[ID_HEADER]
      user = User.find_by(id: user_id)
    end

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

  def frontent_request?
    params[:frontend] && params[:frontend] != 'false'
  end

  def headers_auth?
    (request.headers[LOGIN_HEADER] || request.headers[ID_HEADER]) &&
      request.headers[TOKEN_HEADER]
  end
end
