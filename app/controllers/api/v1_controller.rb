class Api::V1Controller < ShikimoriController
  responders :json # for content rendering on patch & put requests
  respond_to :json

  skip_before_action :touch_last_online
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

  # do not touch it on api access
  def touch_last_online
  end

  def api_error exception
    render(
      json: request.get? ?
        [exception.message] :
        { errors: [exception.message] },
      status: :unprocessable_entity
    )
  end

  def frontent_request?
    params[:frontend] && params[:frontend] != 'false'
  end

  def neko_request?
    request.headers['User-Agent'] == 'Neko'
  end
end
