class AnimeOnline::AnimeVideoAuthorsController < ShikimoriController
  respond_to :json, only: %i[autocomplete]

  def autocomplete
    @collection = AnimeVideoAuthorsQuery.new(params[:search]).complete
  end
end
