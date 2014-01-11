class Api::V1::StudiosController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/studios", "List studios"
  def index
    respond_with Studio.all
  end
end
