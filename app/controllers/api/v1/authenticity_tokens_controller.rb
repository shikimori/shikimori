# TODO: выпилить "token" ключ
class Api::V1::AuthenticityTokensController < Api::V1::ApiController
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/authenticity_token', 'Show an authenticity token'
  def show
    render json: { authenticity_token: form_authenticity_token }
  end
end
