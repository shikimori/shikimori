class Api::V1::AnimesController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id", "Show an anime"
  def show
    @resource = Anime.find(params[:id]).decorate
  end
end
