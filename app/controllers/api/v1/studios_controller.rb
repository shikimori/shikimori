class Api::V1::StudiosController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/studios", "List studios"
  def index
    @collection = Studio.all
    respond_with @collection.to_a
  end
end
