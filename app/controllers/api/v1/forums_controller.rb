class Api::V1::ForumsController < Api::V1::ApiController
  respond_to :json

  api :GET, '/forums', 'List of forums'
  def index
    @collection = Forum.with_aggregated.to_a
    respond_with @collection
  end
end
