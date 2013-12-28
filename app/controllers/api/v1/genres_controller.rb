class Api::V1::GenresController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/genres", "List genres"
  def index
    @collection = Genre.all
  end
end
