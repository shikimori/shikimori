class Api::V1::Profile::HistoryController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/history", "List history"
  def index
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    @resources = current_user
      .all_history
      .order { updated_at.desc }
      .offset(@limit * (@page-1))
      .limit(@limit + 1)

  end
end
