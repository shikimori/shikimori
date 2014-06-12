# TODO: выпилить "token" ключ
class Api::V1::AuthenticityTokensController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/authenticity_token", "Show an authenticity token"
  def show
    render json: { authenticity_token: form_authenticity_token }
  end
end
