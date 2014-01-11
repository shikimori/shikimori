class Api::V1::AnimesController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/animes/:id", "Show an anime"
  def show
    respond_with Anime.find(params[:id]).decorate, serializer: AnimeProfileSerializer
  end
end
