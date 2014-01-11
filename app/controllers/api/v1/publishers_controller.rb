class Api::V1::PublishersController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/publishers", "List publishers"
  def index
    respond_with Publisher.all
  end
end
