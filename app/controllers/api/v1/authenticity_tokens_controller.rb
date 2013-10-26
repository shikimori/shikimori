class Api::V1::AuthenticityTokensController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/authenticity_token", "Show an authenticity token"
  def show
    render json: { token: form_authenticity_token }
  end
end

