class Api::V1::BansController < Api::V1Controller
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/bans', 'List bans'
  def index
    page = [params[:page].to_i, 1].max
    limit = params[:limit].to_i.clamp(1, 30)

    @collection = BansQuery.new.fetch page, limit

    respond_with @collection
  end
end
