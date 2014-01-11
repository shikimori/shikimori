class Api::V1::MangasController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas/:id", "Show a manga"
  def show
    respond_with Manga.find(params[:id]).decorate, serializer: MangaProfileSerializer
  end
end
