class Api::V1::MangasController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/mangas/:id", "Show a manga"
  def show
    @resource = Manga.find(params[:id]).decorate
  end
end
