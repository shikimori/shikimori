class AnimeOnline::AnimeVideoAuthorsController < ShikimoriController
  respond_to :json, only: [:autocomplete, :yandere]

  def autocomplete
    @collection = AnimeVideoAuthorsQuery.new(params[:search]).complete
  end
end
