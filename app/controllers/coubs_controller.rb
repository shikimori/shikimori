class CoubsController < ShikimoriController
  def fetch
    anime = Anime.find params[:id]
    results = Coubs::Fetch.call anime.coub_tags, params[:iterator]

    render json: results
  end

  def autocomplete
    @collection = CoubTagsQuery.new(params[:search]).complete
  end
end
