# TODO: выпилить "token" ключ
class Api::V1::AuthenticityTokensController < Api::V1Controller
  api :GET, '/authenticity_token', 'Show an authenticity token', deprecated: true
  def show
    render json: { authenticity_token: form_authenticity_token }
  end
end
