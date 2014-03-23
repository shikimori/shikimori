class Api::V1::GenresController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/genres", "List genres"
  def index
    @collection = Genre.all.to_a
    respond_with @collection
  end
end
