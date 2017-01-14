class Api::V1::GenresController < Api::V1Controller
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/genres', 'List genres'
  def index
    @collection = Genre.all.to_a
    respond_with @collection
  end
end
