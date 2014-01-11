class Api::V1::Profile::HistoryController < Api::V1::ApiController
  before_filter :authenticate_user!
  respond_to :json, :xml

  api :GET, "/profile/history", "Current user history"
  def index
    respond_with fetch_history current_user
  end

  api :GET, "/profile/history/:id", "Selected user history"
  def show
    respond_with fetch_history User.find_by_nickname(SearchHelper.unescape params[:id])
  end

private
  def fetch_history user
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    @resources = user
      .all_history
      .order { updated_at.desc }
      .offset(@limit * (@page-1))
      .limit(@limit + 1)
      .decorate
  end
end
