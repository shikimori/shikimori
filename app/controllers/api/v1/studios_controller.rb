class Api::V1::StudiosController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/studios", "List studios"
  def index
    @collection = Studio.all
  end
end
