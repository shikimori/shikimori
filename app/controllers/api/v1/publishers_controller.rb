class Api::V1::PublishersController < Api::V1::ApiController
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/publishers", "List publishers"
  def index
    @collection = Publisher.all.to_a
    respond_with @collection
  end
end
