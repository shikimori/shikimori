class Api::V1::BansController < Api::V1::ApiController
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/bans', 'List bans'
  def index
    page = [params[:page].to_i, 1].max
    limit = [[params[:limit].to_i, 1].max, 30].min

    @collection = BansQuery.new.fetch page, limit

    respond_with @collection
  end
end
