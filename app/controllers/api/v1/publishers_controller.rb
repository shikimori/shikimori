class Api::V1::PublishersController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/publishers", "List publishers"
  def index
    @collection = Publisher.all
  end
end
